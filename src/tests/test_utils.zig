const std = @import("std");
const evm = @import("evm");
const Opcode = evm.Opcode;
const Word = @import("constants").Word;

pub fn op(comptime opcode: Opcode) u8 {
    return @intFromEnum(opcode);
}

pub fn volatileStackTestValue(expected_value: Word, bytecode: []const u8) !void {
    const allocator = std.testing.allocator;

    var volatile_host = evm.VolatileHost.init(allocator);
    defer volatile_host.deinit();

    var evm_host = volatile_host.host();

    var evm_interp = try evm.Interpreter.init(allocator, &evm_host, bytecode);
    defer evm_interp.deinit();

    try evm_interp.execute();
    try std.testing.expectEqual(expected_value, evm_interp.stack.peek());
}

pub fn volatileStackTestError(expected_error: anyerror, bytecode: []const u8) !void {
    const allocator = std.testing.allocator;

    var volatile_host = evm.VolatileHost.init(allocator);
    defer volatile_host.deinit();

    var evm_host = volatile_host.host();

    var evm_interp = try evm.Interpreter.init(allocator, &evm_host, bytecode);
    defer evm_interp.deinit();

    try std.testing.expectError(expected_error, evm_interp.execute());
}
