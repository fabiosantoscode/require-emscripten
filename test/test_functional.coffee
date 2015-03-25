
requireEmscripten = require '..'
{compile, patchRequire} = requireEmscripten
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

describe 'patchRequire', () ->
    it 'patches require', () ->
        patchRequire()
        mod = require testcppfile

        ok mod, 'mod exists'
        ok.equal typeof mod, 'object', 'mod is an obj'

        ok.equal typeof mod._foo, 'function', 'mod._foo is a function'

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

    it 'seems to work lel', () ->
        ok toBrowserified('''
            var requireEmscripten = require('require-emscripten');
            var foo = require("''' + testcppfile + '''")._foo;
        ''', __dirname + '/.test-functional-with-browserify.js')

    it 'finds C code and does its thing', () ->
        fs.writeFileSync __dirname + '/./my-c-file.c', 'int foo(){return 2;}'
        ok /_foo/.test toBrowserified('require("./my-c-file.c")')

    it 'can operate on requireEmscripten() calls too (and it would rather!)', () ->
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

