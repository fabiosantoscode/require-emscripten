
var fs = require('fs')
var sh = require('child_process').execSync
var assert = require('assert')

var compile = exports.compile = function (file) {
    var outp = file + '.requireemscripten.js'
    sh('emcc ' + [
        file,
        '-s LINKABLE=1',
        '-s EXPORTED_FUNCTIONS="[\'_foo\']"',
        //'-s ALLOW_MEMORY_GROWTH=1',
        ' -o ' + outp
    ].join(' '))
    //var compiled = fs.readFileSync(outp)
    //compiled = compiled.toString('utf-8')

    return require(outp);

    return eval(['(function(){' +
        'var Module = {}',
        'Module.noInitialRun = true',
        compiled,
        'return Module',
    '}())'].join('\n'))
}

exports.patchRequire = function () {
    require.extensions['.cpp'] =
    require.extensions['.cc'] =
    require.extensions['.c'] = function (module, filename) {
        return compile(filename)
    }
}

