const evm = @import("evm");
const Context = evm.Context;
const constants = @import("constants");
const Word = constants.Word;
const SignedWord = constants.SignedWord;
const utils = @import("evm_utils");

pub inline fn signextend(ctx: *Context) !void {
    const operand1 = ctx.stack.pop();
    const operand2 = ctx.stack.pop();
    try ctx.stack.push(utils.signExtend(operand2, operand1));
}

pub inline fn @"and"(ctx: *Context) !void {
    const operand1 = ctx.stack.pop();
    const operand2 = ctx.stack.pop();
    try ctx.stack.push(operand1 & operand2);
}

pub inline fn @"or"(ctx: *Context) !void {
    const operand1 = ctx.stack.pop();
    const operand2 = ctx.stack.pop();
    try ctx.stack.push(operand1 | operand2);
}

pub inline fn xor(ctx: *Context) !void {
    const operand1 = ctx.stack.pop();
    const operand2 = ctx.stack.pop();
    try ctx.stack.push(operand1 ^ operand2);
}

pub inline fn not(ctx: *Context) !void {
    const operand = ctx.stack.pop();
    try ctx.stack.push(~operand);
}

pub inline fn byte(ctx: *Context) !void {
    const operand1 = ctx.stack.pop();
    const operand2 = ctx.stack.pop();
    try ctx.stack.push(utils.extractIthByte(Word, operand2, operand1));
}

pub inline fn shl(ctx: *Context) !void {
    const operand1 = ctx.stack.pop();
    const operand2 = ctx.stack.pop();
    try ctx.stack.push(operand2 << @as(u8, @truncate(operand1)));
}

pub inline fn shr(ctx: *Context) !void {
    const operand1 = ctx.stack.pop();
    const operand2 = ctx.stack.pop();
    try ctx.stack.push(operand2 >> @as(u8, @truncate(operand1)));
}

pub inline fn sar(ctx: *Context) !void {
    const operand1 = ctx.stack.pop();
    const operand2 = @as(SignedWord, @bitCast(ctx.stack.pop()));
    const result = operand2 >> @as(u8, @truncate(operand1));
    try ctx.stack.push(@as(Word, @bitCast(result)));
}
