var requireEmscripten = require('..')
console.log(requireEmscripten(__dirname + '/main.rs')._foo())

