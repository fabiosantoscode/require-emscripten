'use strict'

var fs = require('fs')
var sh = require('child_process').execSync

var compile = exports.compile = function (file, opt) {
    opt = opt || {}
    var outp = file + '.requireemscripten.js'
    sh('emcc ' + [
        file,
        '-s LINKABLE=1',
        '-s EXPORT_ALL=1',
        ' -o ' + outp
    ].join(' '))

    if (opt.returnFilename) {
        return outp
    }
    return require(outp);
}

exports.patchRequire = function (opt) {
    opt = opt || {}
    var extensions = opt.extensions || ['.cpp', '.cc', '.c']

    function compileAndRequire(module, filename) {
        filename = compile(filename, { returnFilename: true })
        return require.extensions['.js'](module, filename)
    }

    for (var i = 0; i < extensions.length; i++) {
        require.extensions[extensions[i]] = compileAndRequire
    }
}

