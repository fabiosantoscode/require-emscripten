'use strict'

var assert = require('assert')
var path = require('path')
var fs = require('fs')
var cp = require('child_process')
var os = require('os')

module.exports = function requireEmscripten(file, options) {
    assert(path.isAbsolute(file),
        'requireEmscripten() needs an absolute file path, unlike require()!')
    var outFile = file + '.requireemscripten.js'
    if (require.cache && (outFile in require.cache)) {
        // We've already compiled this, and required it.
        // Node has helpfully cached it, so no need to recompile.
        return require(outFile)
    }
    compile(file, options)
    return require(outFile)
}

var shellReplace =
module.exports.shellReplace =
function shellReplace(string, variables) {
    for (var key in variables) if (variables.hasOwnProperty(key)) {
        string = string
            .replace('$' + key, variables[key])
    }
    return string
}

var readConfig =
module.exports.readConfig =
function readConfig(file) {
    var emccExecutable = file.match(/\/\*\s*?require-emscripten-emcc-executable[: ]\s*?(.*?)\s*?\*\//)

    if (emccExecutable) {
        emccExecutable = emccExecutable[1]
    }

    var toBitcode = file.match(/\/\*\s*?require-emscripten-to-bitcode[: ]\s*?(.*?)\s*?\*\//)

    if (toBitcode) {
        toBitcode = toBitcode[1]
    }

    var theComment = file.match(/\/\*\s*?require-emscripten[: ]\s*?(.*?)\s*?\*\//)

    return {
        emccExecutable: emccExecutable,
        toBitcode: toBitcode,
        cliArgs: theComment ? theComment[1].trim() : ''
    }
}

var emccOrEmccBat = os.type() === 'Windows_NT' ? 'emcc.bat' : 'emcc'

var compile =
module.exports.compile =
function (file, config) {
    var outp = file + '.requireemscripten.js'
    var bcOutp = file + '.requireemscripten.bc'

    var inputFile = fs.readFileSync(file, 'utf-8')

    if (!config)
        config = module.exports.readConfig(inputFile, { INPUT: file, OUTPUT: bcOutp })

    if (config.toBitcode) {
        // Input file for emscripten is the .bc output from the user compiler
        var toBitcodeCommand = module.exports.shellReplace(
            config.toBitcode, { INPUT: file, OUTPUT: bcOutp })
        cp.execSync(toBitcodeCommand)
        file = bcOutp
    }

    var command = config.emccExecutable ? config.emccExecutable :
      emccOrEmccBat;

    var preJs = __dirname + '/pre-js.prejs'
    var postJs = __dirname + '/post-js.postjs'

    var commandArgs = [
        file,
        '--pre-js', preJs,
        '--post-js', postJs,
        '--memory-init-file', '0',
        '-s', 'EXPORT_ALL=1',
        '-s', 'LINKABLE=1',
    ];

    commandArgs = commandArgs
        .concat(config.cliArgs ?
            config.cliArgs.split(/\s+/g) :
            [])
        .concat(['-o', outp])

    cp.spawnSync(command, commandArgs)

    if (config.toBitcode) {
        fs.unlinkSync(bcOutp)
    }

    return outp
}

