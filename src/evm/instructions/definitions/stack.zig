const std = @import("std");
const evm = @import("evm");
const Interpreter = evm.Interpreter;
const utils = @import("evm_utils");
const Word = @import("types").Word;

pub inline fn pop(interp: *Interpreter) !void {
    _ = interp.stack.pop();
}

pub inline fn push(interp: *Interpreter, count: u32) !void {
    const frame = interp.frames.top().?;
    const code = frame.executing_contract.code;
    const program_counter = frame.program_counter;

    const bytes = code[program_counter-count..program_counter];
    const value = utils.intFromBigEndianBytes(Word, bytes);
    try interp.stack.push(value);
}

pub inline fn dup(interp: *Interpreter, offset: u32) !void {
    try interp.stack.dup(offset);
}

pub inline fn swap(interp: *Interpreter, offset: u32) !void {
    try interp.stack.swap(offset);
}
