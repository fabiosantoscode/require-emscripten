
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

