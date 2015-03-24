
{compile, patchRequire} = require '..'
ok = require 'assert'
fs = require 'fs'

testcppfile = __dirname + '/.reqemtest.c'
fs.writeFileSync testcppfile, '''
    int foo() {
        return 42;
    }

    int bar(int a, int b) {
        return a + b;
    }
'''

describe 'compile()', () ->
    mod = null

    it 'returns a Module object', () ->
        mod = compile testcppfile
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

