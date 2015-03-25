'use strict'

var fs = require('fs')
var sh = require('child_process').execSync

module.exports = function requireEmscripten(file) {
    return require(compile(file));
}

var compile =
module.exports.compile =
function (file) {
    var outp = file + '.requireemscripten.js'
    sh('emcc ' + [
        file,
        '-s LINKABLE=1',
        '-s EXPORT_ALL=1',
        ' -o ' + outp
    ].join(' '))

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

