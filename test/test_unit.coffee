
reqEm = require '..'
ok = require 'assert'

describe 'readConfig', () ->
    it 'finds opts in the top of files', ()->
        conf = reqEm.readConfig('\n/* require-emscripten -s WARN_ON_UNDEFINED_SYMBOLS=1 lel */\n\n\n').command
        ok.equal conf, '-s WARN_ON_UNDEFINED_SYMBOLS=1 lel'

    it 'doesn\'t fail when no comment found', () ->
        ok.equal reqEm.readConfig('lol some code or something').command, ''

    it 'finds preprocessor commands', () ->
        ok.equal reqEm.readConfig('/* require-emscripten-to-bitcode BITCODER $INPUT $OUTPUT */', { INPUT: 'inpt', OUTPUT: 'outp' }).toBitcode,
            'BITCODER inpt outp'

