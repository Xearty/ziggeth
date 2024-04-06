const evm = @import("evm");
const Context = evm.Context;
const constants = @import("constants");
const Word = constants.Word;
const SignedWord = constants.SignedWord;

pub inline fn lt(ctx: *Context) !void {
    const operand1 = ctx.stack.pop();
    const operand2 = ctx.stack.pop();
    try ctx.stack.push(@as(Word, @as(u1, @bitCast(operand1 < operand2))));
}

pub inline fn gt(ctx: *Context) !void {
    const operand1 = ctx.stack.pop();
    const operand2 = ctx.stack.pop();
    try ctx.stack.push(@as(Word, @as(u1, @bitCast(operand1 > operand2))));
}

pub inline fn slt(ctx: *Context) !void {
    const operand1 = @as(SignedWord, @bitCast(ctx.stack.pop()));
    const operand2 = @as(SignedWord, @bitCast(ctx.stack.pop()));
    const result = @as(Word, @as(u1, @bitCast(operand1 < operand2)));
    try ctx.stack.push(result);
}

pub inline fn sgt(ctx: *Context) !void {
    const operand1 = @as(SignedWord, @bitCast(ctx.stack.pop()));
    const operand2 = @as(SignedWord, @bitCast(ctx.stack.pop()));
    const result = @as(Word, @as(u1, @bitCast(operand1 > operand2)));
    try ctx.stack.push(result);
}

pub inline fn eq(ctx: *Context) !void {
    const operand1 = ctx.stack.pop();
    const operand2 = ctx.stack.pop();
    try ctx.stack.push(@as(Word, @as(u1, @bitCast(operand1 == operand2))));
}

pub inline fn iszero(ctx: *Context) !void {
    const operand = ctx.stack.pop();
    try ctx.stack.push(@as(Word, @as(u1, @bitCast(operand == 0))));
}
