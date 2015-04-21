
reqEm = require '..'
ok = require 'assert'
sinon = require 'sinon'

describe 'readConfig', () ->
    it 'finds opts in the top of files', ()->
        conf = reqEm.readConfig('\n/* require-emscripten -s WARN_ON_UNDEFINED_SYMBOLS=1 lel */\n\n\n').cliArgs
        ok.equal conf, '-s WARN_ON_UNDEFINED_SYMBOLS=1 lel'

    it 'doesn\'t fail when no comment found', () ->
        ok.equal reqEm.readConfig('lol some code or something').cliArgs, ''

    it 'finds preprocessor commands', () ->
        ok.equal reqEm.readConfig('/* require-emscripten-to-bitcode BITCODER $INPUT $OUTPUT */', { INPUT: 'inpt', OUTPUT: 'outp' }).toBitcode,
            'BITCODER $INPUT $OUTPUT'

describe 'compile', () ->

    it 'calls readConfig unless options are passed', sinon.test () ->
        sh = this.stub require('child_process'), 'execSync'
        readConfig = this.stub reqEm, 'readConfig'
        readConfig.returns {}
        readFileSync = this.stub(require('fs'), 'readFileSync')
            .returns('/* foobar.c contents */')
        reqEm.compile('foobar.c')
        ok readConfig.calledOnce, 'readConfig called in compile()'
        ok readConfig.calledWith '/* foobar.c contents */'

        reqEm.compile('foobar.c', {})

        ok readConfig.calledOnce, 'readConfig not called again'

