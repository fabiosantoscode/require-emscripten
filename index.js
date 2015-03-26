'use strict'

var fs = require('fs')
var sh = require('child_process').execSync

module.exports = function requireEmscripten(file) {
    return require(compile(file));
}

var readConfig =
module.exports.readConfig =
function readConfig(file) {
    var theComment = file.match(/\/\*\s*?require-emscripten:?\s*?(.*?)\s*?\*\//)

    if (!theComment) { return '' }

    return theComment[1].trim()
}

var compile =
module.exports.compile =
function (file) {
    var outp = file + '.requireemscripten.js'

    var inputFile = fs.readFileSync(file, 'utf-8')

    var opts = readConfig(inputFile)

    var command = [
        'emcc',
        file,
        '-s EXPORT_ALL=1',
        '-s LINKABLE=1',
        opts,
        '-o ' + outp
    ].join(' ')

    console.log('running command', JSON.stringify(command))

    sh(command)

    return outp
}

module.exports.patchRequire =
function patchRequire(opt) {
    opt = opt || {}
    var extensions = opt.extensions || ['.cpp', '.cc', '.c']

    function compileAndRequire(module, filename) {
        filename = compile(filename)
        return require.extensions['.js'](module, filename)
    }

    for (var i = 0; i < extensions.length; i++) {
        require.extensions[extensions[i]] = compileAndRequire
    }
}

