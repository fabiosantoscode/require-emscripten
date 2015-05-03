
reqEm = require '..'
child_process = require 'child_process'
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

    it 'finds the alternate emcc command/path', () ->
        ok.equal(
            reqEm.readConfig('/* require-emscripten-emcc-executable /path/to/emcc command */').emccExecutable,
            '/path/to/emcc command'
        )

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

    it 'calls `sh.spawnSync` with the emcc command and some args', sinon.test () ->
        sh = this.stub child_process, 'spawnSync'
        this.stub(require('fs'), 'readFileSync')
            .returns '/* some C */'

        reqEm.compile('lel.c',)
        ok sh.calledOnce
        ok sh.calledWith 'emcc'
        ok sh.lastCall.args[1].length > 0

    it 'calls `sh.spawnSync` with alternate emcc command if given through opts', sinon.test () ->
        sh = this.stub child_process, 'spawnSync'
        this.stub(require('fs'), 'readFileSync')
            .returns '/* some C */'

        reqEm.compile('lel.c', { emccExecutable: '/alt/emcc' })
        ok sh.calledOnce
        ok sh.calledWith '/alt/emcc'

