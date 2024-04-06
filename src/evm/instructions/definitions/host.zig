const std = @import("std");
const evm = @import("evm");
const Context = evm.Context;
const constants = @import("constants");
const Word = constants.Word;

pub inline fn sload(ctx: *Context) !void {
    const key = ctx.stack.pop();
    const maybe_value = ctx.storage.load(key);
    if (maybe_value) |value| {
        try ctx.stack.push(value);
    } else {
        const message = try std.fmt.allocPrint(ctx.allocator, "Key {} doesn't exist in storage", .{key});
        defer ctx.allocator.free(message);
        @panic(message);
    }
}

pub inline fn sstore(ctx: *Context) !void {
    const key = ctx.stack.pop();
    const value = @as(Word, @bitCast(ctx.stack.pop()));
    try ctx.storage.store(key, value);
}
