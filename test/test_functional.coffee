
requireEmscripten = require '..'
ok = require 'assert'
fs = require 'fs'
cp = require 'child_process'
sh = cp.execSync

describe 'require("require-emscripten")() in node', () ->
    testcppfile = __dirname + '/reqemtest.c'

    before () ->
        fs.writeFileSync testcppfile, '''
            int foo() {
                return 42;
            }

            int bar(int a, int b) {
                return a + b;
            }
        '''

    after () ->
        try
            fs.unlinkSync testcppfile

    it 'returns a Module object', () ->
        mod = requireEmscripten testcppfile
        ok mod, 'returns a module obj'
        ok.equal typeof mod, 'object'

    worksWithOX = (X) ->
        mod = requireEmscripten testcppfile, cliArgs: "-O#{X}"
        ok mod, 'returns a module obj'
        ok.equal typeof mod, 'object'
        ok mod._foo 'mod._foo exists'
        ok.equal mod._foo(), 42

    it 'Works with -O1', () ->
        worksWithOX(1)

    it 'Works with -O2', () ->
        worksWithOX(2)

    it 'Works with -O3', () ->
        worksWithOX(3)

describe 'compiling rust code', () ->
    rustfile = __dirname + '/test.rs'
    doSkip = true

    before () ->
        fs.writeFileSync rustfile, '''
            /* require-emscripten-to-bitcode: rustc --crate-type lib --emit llvm-bc $INPUT -o $OUTPUT */

            #[no_mangle]
            pub extern fn foo() -> i32 {
                return lel();
            }

            fn lel() -> i32 {
                return 42;
            }
        '''

        try
            v = sh 'rustc --version'
            if v
                doSkip = false

    after () ->
        try
            fs.unlinkSync rustfile

    it 'well, works', () ->
        if doSkip
            return
        rustmod = requireEmscripten rustfile
        ok.equal typeof rustmod, 'object', 'module was returned'
        ok.equal rustmod._foo(), 42, 'module function works'

describe 'browserify integration', () ->
    toBrowserified = (s) ->
        filename = __dirname + '/.test-functional-with-browserify.js'
        fs.writeFileSync(filename, s)
        ret = cp.spawnSync './node_modules/browserify/bin/cmd.js', [
            '-t', (__dirname + '/../browserify/transform.js'),
            filename,
        ]
        try
            fs.unlinkSync filename
        if ret.status is 0
            return ret.stdout.toString()
        throw ret.stderr

    it 'can transform requireEmscripten() calls', () ->
        fs.writeFileSync __dirname + '/my-c-file.c', 'int foo(){return 2;}'
        result = toBrowserified '''
            var requireEmscripten = require('require-emscripten')
            requireEmscripten(__dirname + "/my-c-file.c")
            console.log("YHEA")
        '''

        ok result, 'there is some result'

        console.log result
        ok(/YHEA/.test(result), 'it has our console.log still')
        ok(/_foo/.test(result), 'it has _foo somewhere in it')
        ok(/require.*?\/my-c-file.c/.test(result), 'it contains the require() call redirected to the C file')

    context 'generated code', () ->
        doSkip = false
        before () ->
            try
                version = sh 'phantomjs --version'
                version = (version+'').trim().split('.')
                if +version[0] < 2
                    doSkip = true
            catch e
                console.log e
                doSkip = true

        it 'generated code with -O1 runs in browser', () ->
            runWithOX(1)

        it 'generated code with -O2 runs in browser', () ->
            runWithOX(2)

        it 'generated code with -O3 runs in browser', () ->
            runWithOX(3)

        runWithOX = (x) ->
            if doSkip
                console.log 'Only phantomjs >= 2.x.x can run these tests. Skipping.'
                return

            fs.writeFileSync(
                __dirname + '/my-c-file.c',
                """
                /* require-emscripten: -O#{x} */
                #include <stdio.h>
                int printer(int number) {
                    return number+1;
                }
                """)

            fs.writeFileSync(
                __dirname + '/bundle',
                toBrowserified('''
                    try {
                        var cMod = require('require-emscripten')(__dirname + '/my-c-file.c')
                        console.log(cMod._printer(10))
                    } catch(e) {
                        console.log(e)
                    }
                    phantom.exit(0)
                '''))

            stdout = sh "phantomjs #{__dirname}/bundle"
            if not /11/.test(stdout+'')
                console.log stdout+''
                ok false, 'standard output did not contain expected result!'

        afterEach () ->
            try
                fs.unlinkSync(__dirname + '/my-c-file.c')
            try
                fs.unlinkSync(__dirname + '/bundle')

