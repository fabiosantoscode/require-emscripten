
# require-emscripten

[![Join the chat at https://gitter.im/fabiosantoscode/require-emscripten](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/fabiosantoscode/require-emscripten?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Require C/C++ (and other LLVM languages) in node and in the browser!

This will use Emscripten's `emcc` in your PATH to compile things you require() in node and turn your exported functions into callable javascript functions. Just remember that exported functions in emscripten begin with an underscore ;)

# Example

(test.c is in the example directory in this repo)

    /* I am a counter */
    int foo () {
        static int i = 0;
        return i++;
    }

Here's an example using `patchRequire()` to patch our requires to C/C++ files.

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


# How to install

 * Install and source emscripten so that `emcc` is in your PATH. Refer to their [easy instructions on how to do this](http://kripken.github.io/emscripten-site/docs/getting_started/downloads.html#windows-osx-and-linux-installing-the-portable-sdk).
 * `npm install require-emscripten`

# How to use

 * Either do `require('require-emscripten').patchRequire()` or `var requireEmscripten = require('require-emscripten'); requireEmscripten('/path/to/c-things.c')`.
 * your `require()` / `requireEmscripten()` call will return a Module object straight from Emscripten, it has [this API](http://kripken.github.io/emscripten-site/docs/api_reference/preamble.js.html#preamble-js) and any function you exported from your C code will be in it, but their name will have a leading underscore. EG: `_foo` if your function's name is `foo`.
 * You can write directives in your C/C++ files to customize the emcc command, just add a C-style comment like this: `/* require-emscripten: -O3 */` and the command gets -O3 added as an argument. To see more arguments to the `emcc` command, run `emcc --help`.

# Use in the browser with browserify

Just add `browerify/transform.js` in this repo to your browserify transforms. Refer to the browserify documentation to do so.

This is really important. If it doesn't work for you or you had a hard time doing it, please file an issue.

