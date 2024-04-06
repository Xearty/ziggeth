const evm = @import("evm");
const Context = evm.Context;
const utils = @import("evm_utils");

pub inline fn pop(ctx: *Context) !void {
    _ = ctx.stack.pop();
}

pub inline fn push(ctx: *Context, count: u32) !void {
    const bytes = ctx.bytecode[ctx.program_counter-count..ctx.program_counter];
    const value = utils.wordFromBigEndianBytes(bytes);
    try ctx.stack.push(value);
}

pub inline fn dup(ctx: *Context, offset: u32) !void {
    try ctx.stack.dup(offset);
}

pub inline fn swap(ctx: *Context, offset: u32) !void {
    try ctx.stack.swap(offset);
}
