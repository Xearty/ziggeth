const std = @import("std");
const Host = @import("../../Host.zig");
const Interpreter = @import("../../Interpreter.zig");
const eth_types = @import("eth_types");
const Word = eth_types.Word;

pub inline fn sload(interp: *Interpreter) !void {
    const key = interp.stack.pop();
    const maybe_value = interp.host.sload(69, key);
    if (maybe_value) |value| {
        try interp.stack.push(value);
    } else {
        const message = try std.fmt.allocPrint(interp.allocator, "Key {} doesn't exist in storage", .{key});
        defer interp.allocator.free(message);
        @panic(message);
    }
}

pub inline fn sstore(interp: *Interpreter) !void {
    const key = interp.stack.pop();
    const value = @as(Word, @bitCast(interp.stack.pop()));
    interp.host.sstore(69, key, value);
}
