
module.exports = function requireEmscripten() {
    throw new Error('require-emscripten: It seems like you\'re not using the browserify transform. If you are, it\'s broken. Report it!')
}

module.exports.compile = function (filename) {
    // Do no work here
    // But return expected thing
    return filename + '.requireemscripten.js'
}

