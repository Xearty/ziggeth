const std = @import("std");
const evm = @import("evm");
const utils = @import("evm_utils");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const bytecode: []const u8 = &.{
        @intFromEnum(evm.Opcode.PUSH1), 69,
        @intFromEnum(evm.Opcode.PUSH1), 71,
        @intFromEnum(evm.Opcode.PUSH1), 72,
        @intFromEnum(evm.Opcode.PUSH1), 73,  // value
        @intFromEnum(evm.Opcode.PUSH1), 0x5, // key
        @intFromEnum(evm.Opcode.SSTORE),
        @intFromEnum(evm.Opcode.PUSH1), 0x5, // key
        @intFromEnum(evm.Opcode.SLOAD),
        @intFromEnum(evm.Opcode.PUSH1), 69,  // value
        @intFromEnum(evm.Opcode.PUSH1), 100, // key
        @intFromEnum(evm.Opcode.SSTORE),
        @intFromEnum(evm.Opcode.PUSH1), 221,  // value
        @intFromEnum(evm.Opcode.PUSH1), 242, // key
        @intFromEnum(evm.Opcode.SSTORE),
    };

    var evm_context = evm.Context.init(allocator, bytecode);
    defer evm_context.deinit();

    try evm.execute(&evm_context);
    try evm_context.prettyPrint();

    const decompiled_bytecode = try evm.decompile(allocator, bytecode);
    defer allocator.free(decompiled_bytecode);
    utils.printBoxed("Decompiled Bytecode", decompiled_bytecode);
}

