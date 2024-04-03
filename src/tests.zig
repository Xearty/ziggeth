const std = @import("std");
const testing = std.testing;
const expect = testing.expect;

const evm = @import("evm");

test "ADD instruction" {
    var evm_context = evm.Context.init(std.testing.allocator);
    defer evm_context.deinit();

    const bytecode: []const u8 = &.{
        @intFromEnum(evm.Opcode.PUSH1), 0x1,
        @intFromEnum(evm.Opcode.PUSH1), 0x2,
        @intFromEnum(evm.Opcode.ADD),
    };
    try evm.executeBytecode(&evm_context, bytecode);
    try expect(evm_context.peek() == 0x3);
}
