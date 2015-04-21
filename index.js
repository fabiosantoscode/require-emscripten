'use strict'

var fs = require('fs')
var cp = require('child_process')

module.exports = function requireEmscripten(file, options) {
    return require(module.exports.compile(file, options));
}

var shellReplace =
module.exports.shellReplace =
function shellReplace(string, variables) {
    for (var key in variables) if (variables.hasOwnProperty(key)) {
        string = string
            .replace(new RegExp('\\$' + key, 'g'), variables[string])
    }
}

var readConfig =
module.exports.readConfig =
function readConfig(file) {
    var toBitcode = file.match(/\/\*\s*?require-emscripten-to-bitcode[: ]\s*?(.*?)\s*?\*\//)

    if (toBitcode) {
        toBitcode = toBitcode[1]
    }

    var theComment = file.match(/\/\*\s*?require-emscripten[: ]\s*?(.*?)\s*?\*\//)

    return {
        toBitcode: toBitcode,
        cliArgs: theComment ? theComment[1].trim() : ''
    }
}

var compile =
module.exports.compile =
function (file, config) {
    var outp = file + '.requireemscripten.js'
    var bcOutp = file + '.requiremscripten.bc'

    var inputFile = fs.readFileSync(file, 'utf-8')

    if (!config)
        config = module.exports.readConfig(inputFile, { INPUT: file, OUTPUT: bcOutp })

    if (config.toBitcode) {
        // Input file for emscripten is the .bc output from the user compiler
        file = bcOutp
        cp.execSync(
            module.exports.shellReplace(
                config.toBitcode, { INPUT: file, OUTPUT: bcOutp }))
    }

    var command = [
        'emcc',
        file,
        '--pre-js pre-js.prejs',
        '--post-js post-js.postjs',
        '--memory-init-file 0',
        '-s EXPORT_ALL=1',
        '-s LINKABLE=1',
        config.cliArgs,
        '-o ' + outp
    ].join(' ')

    cp.execSync(command)

    if (config.toBitcode) {
        fs.unlinkSync(bcOutp)
    }

    return outp
}

