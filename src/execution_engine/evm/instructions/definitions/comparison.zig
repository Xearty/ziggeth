const Interpreter = @import("../../Interpreter.zig");
const eth_types = @import("eth_types");
const Word = eth_types.Word;
const SignedWord = eth_types.SignedWord;

pub inline fn lt(interp: *Interpreter) !void {
    const operand1 = interp.stack.pop();
    const operand2 = interp.stack.pop();
    try interp.stack.push(@as(Word, @as(u1, @bitCast(operand1 < operand2))));
}

pub inline fn gt(interp: *Interpreter) !void {
    const operand1 = interp.stack.pop();
    const operand2 = interp.stack.pop();
    try interp.stack.push(@as(Word, @as(u1, @bitCast(operand1 > operand2))));
}

pub inline fn slt(interp: *Interpreter) !void {
    const operand1 = @as(SignedWord, @bitCast(interp.stack.pop()));
    const operand2 = @as(SignedWord, @bitCast(interp.stack.pop()));
    const result = @as(Word, @as(u1, @bitCast(operand1 < operand2)));
    try interp.stack.push(result);
}

pub inline fn sgt(interp: *Interpreter) !void {
    const operand1 = @as(SignedWord, @bitCast(interp.stack.pop()));
    const operand2 = @as(SignedWord, @bitCast(interp.stack.pop()));
    const result = @as(Word, @as(u1, @bitCast(operand1 > operand2)));
    try interp.stack.push(result);
}

pub inline fn eq(interp: *Interpreter) !void {
    const operand1 = interp.stack.pop();
    const operand2 = interp.stack.pop();
    try interp.stack.push(@as(Word, @as(u1, @bitCast(operand1 == operand2))));
}

pub inline fn iszero(interp: *Interpreter) !void {
    const operand = interp.stack.pop();
    try interp.stack.push(@as(Word, @as(u1, @bitCast(operand == 0))));
}
