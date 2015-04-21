'use strict'

var fs = require('fs')
var sh = require('child_process').execSync

module.exports = function requireEmscripten(file) {
    return require(compile(file));
}

var readConfig =
module.exports.readConfig =
function readConfig(file, shellReplace) {
    var toBitcode = file.match(/\/\*\s*?require-emscripten-to-bitcode[: ]\s*?(.*?)\s*?\*\//)

    if (toBitcode) {
        toBitcode = toBitcode[1]

        Object.keys(shellReplace).forEach(function (key) {
            toBitcode = toBitcode.replace(new RegExp('\\$' + key, 'g'), shellReplace[key])
        })
    }

    var theComment = file.match(/\/\*\s*?require-emscripten[: ]\s*?(.*?)\s*?\*\//)

    return {
        toBitcode: toBitcode,
        command: theComment ? theComment[1].trim() : ''
    }
}

var compile =
module.exports.compile =
function (file) {
    var outp = file + '.requireemscripten.js'
    var bcOutp = file + '.requiremscripten.bc'

    var inputFile = fs.readFileSync(file, 'utf-8')

    var config = readConfig(inputFile, { INPUT: file, OUTPUT: bcOutp })

    if (config.toBitcode) {
        // Input file for emscripten is the .bc output from the user compiler
        file = bcOutp
        sh(config.toBitcode)
    }

    var command = [
        'emcc',
        file,
        '--pre-js pre-js.prejs',
        '--post-js post-js.postjs',
        '--memory-init-file 0',
        '-s EXPORT_ALL=1',
        '-s LINKABLE=1',
        config.command,
        '-o ' + outp
    ].join(' ')

    sh(command)

    if (config.toBitcode) {
        fs.unlinkSync(bcOutp)
    }

    return outp
}

