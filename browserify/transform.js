'use strict'

var through = require('through')
var fs = require('fs')
var reqEm = require('..')

var everything = ''
var everymodule = []

function write(d) {
    everything += d
}

function end() {
    this.queue(everything)
    this.queue(null)
}

module.exports = function (file) {
    console.log('exporting plugin')
    if (/\.(cpp|cc|c)$/.test(file)) {
        var all = ''
        return through(function write(d) {
            all += d
        }, function end(){
            var fname = reqEm.compile(file)
            this.queue(fs.readFileSync(fname))
            this.queue(null)
        })
    }
    return through(write, end)
}

