'use strict'

var through = require('through')
var stream = require('stream')
var fs = require('fs')
var path = require('path')
var staticMod = require('static-module')
var reqEm = require('..')

module.exports = function (file) {
    // Replaces require('require-emscripten')('file.c') (and variations thereof) with require('file.c')
    var dir = path.dirname(file)
    var fakeRequireEmscripten =
    function fakeRequireEmscripten (requiredFile) {
        var f = reqEm.compile(
            path.join(dir, requiredFile))
        return 'require("' + f + '")'
    }
    fakeRequireEmscripten.patchRequire = function () { return '' }
    return staticMod({
        'require-emscripten': fakeRequireEmscripten,
    }, {
        vars: { __dirname:  path.basename(file) }
    })
}

