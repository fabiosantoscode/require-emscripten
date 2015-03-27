require('..').patchRequire({ extensions: ['.rs'] })
console.log(require('./main.rs')._foo())

