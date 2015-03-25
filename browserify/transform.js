'use strict'

var through = require('through')
var fs = require('fs')
var staticMod = require('static-module')
var reqEm = require('..')

module.exports = function (file) {
    if (/\.(cpp|cc|c)$/.test(file)) {
        var all = ''
        return through(function write(d) {
            all += d
        }, function end(){
            var fname = reqEm.compile(file)
            this.queue(fs.readFileSync(fname))
            this.queue(null)
        })
    } else {
        // Replaces require('require-emscripten')('file.c') (and variations thereof) with require('file.c')
        return staticMod({
            'require-emscripten': function (requiredFile) {
                return 'require("' + requiredFile.replace('"', '\\"') + '");'
            }
        })
    }
}

