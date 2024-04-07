const std = @import("std");
const evm = @import("evm");
const Opcode = evm.Opcode;
const Word = @import("constants").Word;

pub fn op(comptime opcode: Opcode) u8 {
    return @intFromEnum(opcode);
}

pub fn basicValueTest(expected_value: Word, bytecode: []const u8) !void {
    var evm_interp = evm.Interpreter.init(std.testing.allocator, bytecode);
    defer evm_interp.deinit();

    try evm.execute(&evm_interp);
    try std.testing.expectEqual(expected_value, evm_interp.stack.peek());
}
