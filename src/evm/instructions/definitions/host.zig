const std = @import("std");
const evm = @import("evm");
const Host = evm.Host;
const Interpreter = evm.Interpreter;
const types = @import("types");
const Word = types.Word;

pub inline fn sload(interp: *Interpreter) !void {
    const key = interp.stack.pop();
    const maybe_value = interp.host.sload(key);
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
    interp.host.sstore(key, value);
}
