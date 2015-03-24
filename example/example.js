
var requireEmscripten = require('require-emscripten')

// Patch our require() function so we can require C and stuff
requireEmscripten.patchRequire()

var counter = require('./test.c')._foo


log(counter())  // -> 0
log(counter())  // -> 1
log(counter())  // -> 2
log(counter())  // -> 3
log('yay!')

// Here's how we output
function log(msg) {
    if (typeof document !== 'undefined' && document.body) {
        var p = document.createElement('p')
        p.appendChild(document.createTextNode(msg))
        document.body.appendChild(p)
    } else {
        console.log(msg)
    }
}


