/* require-emscripten-to-bitcode: rustc --crate-type lib --emit llvm-bc $INPUT -o $OUTPUT */

#[no_mangle]
pub extern fn foo() -> i32 {
    return lel();
}

fn lel() -> i32 {
    return 42;
}

