'use strict'

var fib = require('require-emscripten')(__dirname + '/fib.c')._fibonacci

var fibJs = require('./fib.js')

console.log('calculating 10000 fibonaccis in requireEmscripten\'d C')
var start = +new Date()
for (var i = 0; i < 10000; i++) {
    var result = fib(1000)
}
console.log('Took ' + (+new Date() - start) + 'ms')
console.log('calculating 10000 JS fibonaccis in java scripts')
var start = +new Date()
for (var i = 0; i < 10000; i++) {
    var result = fibJs(1000)
}
console.log('Took ' + (+new Date() - start) + 'ms')
