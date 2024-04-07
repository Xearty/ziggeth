const std = @import("std");
const evm = @import("evm");
const Interpreter = evm.Interpreter;
const constants = @import("constants");
const Word = constants.Word;

pub inline fn sload(interp: *Interpreter) !void {
    const key = interp.stack.pop();
    const maybe_value = interp.storage.load(key);
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
    try interp.storage.store(key, value);
}
