
# require-emscripten

Require C/C++ (and other LLVM languages) in node and in the browser!

This will use `emcc` in your PATH to compile things you require() in node and give them to you in java scripts. Just remember that exported functions in emscripten begin with an underscore ;)

# Example

(test.c is in the example directory in this repo)

    require('require-emscripten').patchRequire()
    var counter = require('./example/test.c')._foo  // do NOT let node.js print the whole module to the console. It will get your CPU to 100% and take AGES
    console.log(counter())  // -> 0
    console.log(counter())  // -> 1
    console.log(counter())  // -> 2

If you don't want to patch the require() function (or want to use emscripten on source files which are not .c or .cpp), you can use requireEmscripten as a function:

    var requireEmscripten = require('require-emscripten')
    var counter = requireEmscripten(__dirname + '/example/test.c')._foo  // do NOT let node.js print the whole module to the console. It will get your CPU to 100% and take AGES
    console.log(counter())  // -> 0
    console.log(counter())  // -> 1
    console.log(counter())  // -> 2


# How to use

 * Install and source emscripten so that `emcc` is in your PATH. Refer to their easy instructions on how to do this.
 * `npm install require-emscripten`
 * Either do `require('require-emscripten').patchRequire()` or `var requireEmscripten = require('require-emscripten'); requireEmscripten('/path/to/c-things.c')`.


# Use in the browser with browserify

Just add `browerify/transform.js` in this repo to your browserify transforms. Refer to the browserify documentation to do so.

This is really important. If it doesn't work for you or you had a hard time doing it, please file an issue.

