const std = @import("std");
const evm = @import("evm");
const Opcode = evm.Opcode;
const Word = @import("constants").Word;

pub fn op(comptime opcode: Opcode) u8 {
    return @intFromEnum(opcode);
}

pub fn basicValueTest(expected_value: Word, bytecode: []const u8) !void {
    const allocator = std.testing.allocator;

    var host_mock = evm.HostMock.init(allocator);
    defer host_mock.deinit();

    var evm_host = host_mock.host();

    var evm_interp = try evm.Interpreter.init(allocator, &evm_host, bytecode);
    defer evm_interp.deinit();

    try evm.execute(&evm_interp);
    try std.testing.expectEqual(expected_value, evm_interp.stack.peek());
}
