const evm = @import("evm");
const Context = evm.Context;
const constants = @import("constants");
const Word = constants.Word;
const SignedWord = constants.SignedWord;
const math = @import("math");

pub inline fn add(ctx: *Context) !void {
    const operand1 = ctx.stack.pop();
    const operand2 = ctx.stack.pop();
    try ctx.stack.push(operand1 +% operand2);
}

pub inline fn mul(ctx: *Context) !void {
    const operand1 = ctx.stack.pop();
    const operand2 = ctx.stack.pop();
    try ctx.stack.push(operand1 *% operand2);
}

pub inline fn sub(ctx: *Context) !void {
    const operand1 = ctx.stack.pop();
    const operand2 = ctx.stack.pop();
    try ctx.stack.push(operand1 -% operand2);
}

pub inline fn div(ctx: *Context) !void {
    const operand1 = ctx.stack.pop();
    const operand2 = ctx.stack.pop();
    try ctx.stack.push(operand1 / operand2);
}

pub inline fn sdiv(ctx: *Context) !void {
    const operand1 = @as(SignedWord, @bitCast(ctx.stack.pop()));
    const operand2 = @as(SignedWord, @bitCast(ctx.stack.pop()));
    const result = @divTrunc(operand1, operand2);
    try ctx.stack.push(@as(Word, @bitCast(result)));
}

pub inline fn mod(ctx: *Context) !void {
    const operand1 = ctx.stack.pop();
    const operand2 = ctx.stack.pop();
    try ctx.stack.push(operand1 % operand2);
}

pub inline fn smod(ctx: *Context) !void {
    const operand1 = @as(SignedWord, @bitCast(ctx.stack.pop()));
    const operand2 = @as(SignedWord, @bitCast(ctx.stack.pop()));
    const result = @mod(operand1, operand2);
    try ctx.stack.push(@as(Word, @bitCast(result)));
}

pub inline fn addmod(ctx: *Context) !void {
    const operand1 = ctx.stack.pop();
    const operand2 = ctx.stack.pop();
    const operand3 = ctx.stack.pop();
    const result = (operand1 +% operand2) % operand3;
    try ctx.stack.push(result);
}

pub inline fn mulmod(ctx: *Context) !void {
    const operand1 = ctx.stack.pop();
    const operand2 = ctx.stack.pop();
    const operand3 = ctx.stack.pop();
    const result = (operand1 *% operand2) % operand3;
    try ctx.stack.push(result);
}

pub inline fn exp(ctx: *Context) !void {
    const operand1 = ctx.stack.pop();
    const operand2 = ctx.stack.pop();
    try ctx.stack.push(math.pow(Word, operand1, operand2));
}
