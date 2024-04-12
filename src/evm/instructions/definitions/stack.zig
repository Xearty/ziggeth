const evm = @import("evm");
const Interpreter = evm.Interpreter;
const utils = @import("evm_utils");
const Word = @import("constants").Word;

pub inline fn pop(interp: *Interpreter) !void {
    _ = interp.stack.pop();
}

pub inline fn push(interp: *Interpreter, count: u32) !void {
    const bytes = interp.bytecode[interp.program_counter-count..interp.program_counter];
    const value = utils.intFromBigEndianBytes(Word, bytes);
    try interp.stack.push(value);
}

pub inline fn dup(interp: *Interpreter, offset: u32) !void {
    try interp.stack.dup(offset);
}

pub inline fn swap(interp: *Interpreter, offset: u32) !void {
    try interp.stack.swap(offset);
}
