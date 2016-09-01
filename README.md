
# require-emscripten

[![Join the chat at https://gitter.im/fabiosantoscode/require-emscripten](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/fabiosantoscode/require-emscripten?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) [![Build Status](https://travis-ci.org/fabiosantoscode/require-emscripten.svg?branch=master)](https://travis-ci.org/fabiosantoscode/require-emscripten)

Require C/C++ (and other LLVM languages) in node and in the browser!

This will use Emscripten's `emcc` in your PATH to compile things you require() in node and turn your exported functions into callable javascript functions. Just remember that exported functions in emscripten begin with an underscore ;)

# Example

(test.c is in the example directory in this repo)
```c++
/* I am a counter */
int foo () {
    static int i = 0;
    return i++;
}
```

Open up the node console and type:
```js
const requireEmscripten = require('require-emscripten')
const counter = requireEmscripten(__dirname + '/example/test.c')._foo  // do NOT let node.js print the whole module to the console. It will get your CPU to 100% and take AGES

console.log(counter())  // -> 0
console.log(counter())  // -> 1
console.log(counter())  // -> 2
```

# How to install

 * Install and source emscripten so that `emcc` is in your PATH. Refer to their [easy instructions on how to do this](http://kripken.github.io/emscripten-site/docs/getting_started/downloads.html#windows-osx-and-linux-installing-the-portable-sdk).
 * `npm install require-emscripten`

# How to use

 * `var requireEmscripten = require('require-emscripten'); requireEmscripten('/path/to/c-things.c')`.
 * your `requireEmscripten()` call will return a Module object straight from Emscripten, it has [this API](http://kripken.github.io/emscripten-site/docs/api_reference/preamble.js.html#preamble-js) and any function you exported from your C code will be in it, but their name will have a leading underscore. EG: `_foo` if your function's name is `foo`.
 * You can write directives in your C/C++ files to customize the emcc command, just add a C-style comment like this: `/* require-emscripten: -O3 */` and the command gets -O3 added as an argument. To see more arguments to the `emcc` command, run `emcc --help`.

# Use in the browser with browserify

Add `browerify/transform.js` in this repo to your browserify transforms. Refer to the browserify documentation to do so.

If Browserify complains about the (excellent) `ws` module not being installed, add the --ignore-missing option to your browserify incantation (Thanks @nfroidure!). This is an emscripten soft dependency which your project will probably not need, but browserify will not know this and do its job on that `require("ws")` call. If your project does need it, just install it ;)

This feature of require-emscripten is really important. If it doesn't work for you or you had a hard time doing it, please file an issue and I will try to fix it.


# API


## var requireEmscripten = require('require-emscripten')

This loads requireEmscripten into node. Basic stuff. requireEmscripten is a function but it does have a couple of methods:


## var myModule = requireEmscripten(__dirname + '/my-module.c'/*, options?*/);

Compiles a file into JS using emscripten, then requires it. Basically `sh('emcc $filename -o $filename.requireemscripten.js'); return require(filename + '.requireemscripten.js');`

You can customize the arguments passed to `emcc` by adding special comments to your files you want to compile. You can also pass an options hash as the second argument.

## myModule (a compiled Module object which you got from requireEmscripten() or require())

This is an Emscripten Module object. Refer to their docs to figure out how to work with it, but the basics are:

 * DO NOT let node print this to the console, unless you want node to freeze for a long time. You may do this accidentally in the node REPL if you just go in and type `requireEmscripten('/some/c/file.c')` because the REPL prints the values in it. Instead do `var myModule = ...` and you're safe.
 * Your exported functions begin with an underscore. So instead of calling `myModule.foo`, call `myModule._foo()`
 * If they're not here it means you didn't export them. In c++ this means you have to wrap them in an `extern "C" { ... }` thing. In rust, this means it must be marked as `#[no_mangle]` (new line) `pub extern fn`. Etc. Refer to your language's documentation to figure out how they export things to shared object libraries and this should be pretty much the same.


## requireEmscripten(__dirname + '/my-module.c', { toBitcode: 'my-compiler --input-file $INPUT --output-llvm $OUTPUT', cliArgs: '-O2' });

The second argument to `requireEmscripten` is an object containing options. These are the same options you can pass on the top of your C/C++ files, albeit passed as a plain JS object.

The `emccExecutable` option changes the `emcc` executable. By default it just uses `emcc` from your PATH.

The `toBitcode` option denotes a command you might want to use on the file before emscripten sees it. For example, since emscripten cannot read Lisp or Rust, you can put a Rust or Clasp (LLVM Lisp) compilation command in this option. Use `$INPUT` and `$OUTPUT` in this string. They will be replaced with absolute paths to your input and output (llvm bitcode) files, respectively.

The `cliArgs` option is an array containing more CLI arguments to the `emcc` command. Examples are `-O2` to enable some optimization.

Putting it all together:

```js
requireEmscripten(__dirname + '/filename.c', {
    emccExecutable: 'emcc',  /*
        Your own alternate `emcc` executable */
    toBitcode: 'command-to-turn-filename.c-into-bitcode',  /*
        A command which turns your file into LLVM bitcode. Useful
        to compile LLVM languages with this, because emscripten
        only recognizes C/C++ files. Read more below. */
    cliArgs: ['extra arguments to emcc', 'such as', '-O3']  /*
        Pass more arguments to emcc. */
})
```

None of these are mandatory.

# Directives to the compiler

You put these in your C/C++/whatever files.


## `/* require-emscripten-emcc-executable: /alt/emcc */`

This changes the `emcc` executable we use. Same as the `emccExecutable` option.


## `/* require-emscripten: ... */`

Use this to add arguments to the `emcc` command. By default, require-emscripten will do 

    $ emcc (file-you-required) -s EXPORT_ALL=1 -s LINKABLE=1 -o (file-you-required.emscripten.js)

If you add this to the top of your C file:

    /* require-emscripten: -O3 */

Then the command becomes:

    $ emcc (file-you-required) -s EXPORT_ALL=1 -s LINKABLE=1 -o (file-you-required.emscripten.js) -O3


## `/* require-emscripten-to-bitcode: ... */`

If your language is not recognized by `emcc`, you need to find another way to compile it to LLVM bitcode, which emcc understands, and is a common target.

To do that, just write a command in this option and require-emscripten will execute it.

So if you're writing [rust](http://rust-lang.org) (which compiles to LLVM bitcode), you can use this directive to tell require-emscripten how to build you some rust :)


Some variables are expanded:

 * `$INPUT` - The file this comment is on
 * `$OUTPUT` - The file where require-emscripten is hoping to see some LLVM bitcode.

So for example, for rust (see more in rust-example/example.js and rust-example/main.rs) put this directive on the top of the file:

    /* require-emscripten-to-bitcode: rustc --crate-type lib --emit llvm-bc $INPUT -o $OUTPUT */

The above directive tells require-emscripten to run the following command before compiling:

    rustc --crate-type lib --emit llvm-bc (/my/rust/file.rs) -o (/my/rust/file.rs.requireemscripten.bc)

It calls the rust compiler, tells it it's building a library and to write some bitcode. The bitcode ends up in $OUTPUT, so that require-emscripten can tell emcc to read it, and everything is well.

