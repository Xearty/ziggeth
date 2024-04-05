const std = @import("std");
const evm = @import("evm");
const Opcode = evm.Opcode;
const Word = @import("constants").Word;

pub fn op(comptime opcode: Opcode) u8 {
    return @intFromEnum(opcode);
}

pub fn basicValueTest(expected_value: Word, bytecode: []const u8) !void {
    var evm_context = evm.Context.init(std.testing.allocator, bytecode);
    defer evm_context.deinit();

    try evm.execute(&evm_context);
    try std.testing.expect(evm_context.stack.peek() == expected_value);
}
