const Interpreter = @import("../../Interpreter.zig");
const eth_types = @import("eth_types");
const Word = eth_types.Word;
const SignedWord = eth_types.SignedWord;
const utils = @import("utils");

pub inline fn signextend(interp: *Interpreter) !void {
    const operand1 = interp.stack.pop();
    const operand2 = interp.stack.pop();
    try interp.stack.push(utils.signExtend(operand2, operand1));
}

pub inline fn @"and"(interp: *Interpreter) !void {
    const operand1 = interp.stack.pop();
    const operand2 = interp.stack.pop();
    try interp.stack.push(operand1 & operand2);
}

pub inline fn @"or"(interp: *Interpreter) !void {
    const operand1 = interp.stack.pop();
    const operand2 = interp.stack.pop();
    try interp.stack.push(operand1 | operand2);
}

pub inline fn xor(interp: *Interpreter) !void {
    const operand1 = interp.stack.pop();
    const operand2 = interp.stack.pop();
    try interp.stack.push(operand1 ^ operand2);
}

pub inline fn not(interp: *Interpreter) !void {
    const operand = interp.stack.pop();
    try interp.stack.push(~operand);
}

pub inline fn byte(interp: *Interpreter) !void {
    const operand1 = interp.stack.pop();
    const operand2 = interp.stack.pop();
    try interp.stack.push(utils.extractIthByte(Word, operand2, @truncate(operand1)));
}

pub inline fn shl(interp: *Interpreter) !void {
    const operand1 = interp.stack.pop();
    const operand2 = interp.stack.pop();
    try interp.stack.push(operand2 << @as(u8, @truncate(operand1)));
}

pub inline fn shr(interp: *Interpreter) !void {
    const operand1 = interp.stack.pop();
    const operand2 = interp.stack.pop();
    try interp.stack.push(operand2 >> @as(u8, @truncate(operand1)));
}

pub inline fn sar(interp: *Interpreter) !void {
    const operand1 = interp.stack.pop();
    const operand2 = @as(SignedWord, @bitCast(interp.stack.pop()));
    const result = operand2 >> @as(u8, @truncate(operand1));
    try interp.stack.push(@as(Word, @bitCast(result)));
}
