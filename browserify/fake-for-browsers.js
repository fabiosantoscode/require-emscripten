
module.exports = function requireEmscripten() {
    throw new Error('Not implemented: calling requireEmscripten in browserified code. call requireEmscripten.patchRequire() and then use the normal require.')
}

module.exports.compile = function (filename) {
    // Do no work here
    // But return expected thing
    return filename + '.requireemscripten.js'
}

module.exports.patchRequire = function () {
    // Do no work here
    // Real work is done in the transform :)
    return;
}

