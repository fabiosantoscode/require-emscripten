'use strict'

var fs = require('fs')
var sh = require('child_process').execSync

var compile = exports.compile = function (file) {
    var outp = file + '.requireemscripten.js'
    sh('emcc ' + [
        file,
        '-s LINKABLE=1',
        '-s EXPORT_ALL=1',
        ' -o ' + outp
    ].join(' '))

    return require(outp);
}

exports.patchRequire = function (opt) {
    opt = opt || {}
    var extensions = opt.extensions || ['.cpp', '.cc', '.c']

    function compileAndRequire(module, filename) {
        compile(filename)
        filename += '.requireemscripten.js'
        return require.extensions['.js'](module, filename)
    }

    for (var i = 0; i < extensions.length; i++) {
        require.extensions[extensions[i]] = compileAndRequire
    }
}

