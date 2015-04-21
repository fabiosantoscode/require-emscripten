
requireEmscripten = require '..'
ok = require 'assert'
fs = require 'fs'
sh = require('child_process').execSync

testcppfile = __dirname + '/.reqemtest.c'
fs.writeFileSync testcppfile, '''
    int foo() {
        return 42;
    }

    int bar(int a, int b) {
        return a + b;
    }
'''

describe 'require("require-emscripten")()', () ->
    mod = null

    it 'returns a Module object', () ->
        mod = requireEmscripten testcppfile
        ok mod, 'returns a module obj'
        ok.equal typeof mod, 'object'

    it 'returns callable useful functions', () ->
        ok mod._foo, 'mod.foo exists'
        ok.equal typeof mod._foo, 'function', 'mod.foo is a func'
        ok.equal mod._foo(), 42

describe 'browserify integration', () ->
    toBrowserified = (s) ->
        filename = filename || '.test-functional-with-browserify.js'
        fs.writeFileSync(__dirname + '/' + filename, s)
        return sh [
            './node_modules/browserify/bin/cmd.js',
            '-t ' + __dirname + '/../browserify/transform.js',
            __dirname + '/' + filename,
        ].join ' '

    it 'can transform requireEmscripten() calls', () ->
        fs.writeFileSync __dirname + '/./my-c-file.c', 'int foo(){return 2;}'
        result = toBrowserified '''
            var requireEmscripten = require('require-emscripten')
            requireEmscripten("./my-c-file.c")
            console.log("YHEA")
        '''

        ok result, 'there is some result'

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
                        var cMod = require('require-emscripten')('./my-c-file.c')
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

