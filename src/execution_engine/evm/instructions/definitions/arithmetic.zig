const Interpreter = @import("../../Interpreter.zig");
const eth_types = @import("eth_types");
const Word = eth_types.Word;
const SignedWord = eth_types.SignedWord;
const math = @import("math");

pub inline fn add(interp: *Interpreter) !void {
    const operand1 = interp.stack.pop();
    const operand2 = interp.stack.pop();
    try interp.stack.push(operand1 +% operand2);
}

pub inline fn mul(interp: *Interpreter) !void {
    const operand1 = interp.stack.pop();
    const operand2 = interp.stack.pop();
    try interp.stack.push(operand1 *% operand2);
}

pub inline fn sub(interp: *Interpreter) !void {
    const operand1 = interp.stack.pop();
    const operand2 = interp.stack.pop();
    try interp.stack.push(operand1 -% operand2);
}

pub inline fn div(interp: *Interpreter) !void {
    const operand1 = interp.stack.pop();
    const operand2 = interp.stack.pop();
    try interp.stack.push(operand1 / operand2);
}

pub inline fn sdiv(interp: *Interpreter) !void {
    const operand1 = @as(SignedWord, @bitCast(interp.stack.pop()));
    const operand2 = @as(SignedWord, @bitCast(interp.stack.pop()));
    const result = @divTrunc(operand1, operand2);
    try interp.stack.push(@as(Word, @bitCast(result)));
}

pub inline fn mod(interp: *Interpreter) !void {
    const operand1 = interp.stack.pop();
    const operand2 = interp.stack.pop();
    try interp.stack.push(operand1 % operand2);
}

pub inline fn smod(interp: *Interpreter) !void {
    const operand1 = @as(SignedWord, @bitCast(interp.stack.pop()));
    const operand2 = @as(SignedWord, @bitCast(interp.stack.pop()));
    const result = @mod(operand1, operand2);
    try interp.stack.push(@as(Word, @bitCast(result)));
}

pub inline fn addmod(interp: *Interpreter) !void {
    const operand1 = interp.stack.pop();
    const operand2 = interp.stack.pop();
    const operand3 = interp.stack.pop();
    const result = (operand1 +% operand2) % operand3;
    try interp.stack.push(result);
}

pub inline fn mulmod(interp: *Interpreter) !void {
    const operand1 = interp.stack.pop();
    const operand2 = interp.stack.pop();
    const operand3 = interp.stack.pop();
    const result = (operand1 *% operand2) % operand3;
    try interp.stack.push(result);
}

pub inline fn exp(interp: *Interpreter) !void {
    const operand1 = interp.stack.pop();
    const operand2 = interp.stack.pop();
    try interp.stack.push(math.pow(Word, operand1, operand2));
}
