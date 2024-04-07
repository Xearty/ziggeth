const std = @import("std");
const evm = @import("evm");
const utils = @import("evm_utils");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const bytecode: []const u8 = &.{
        @intFromEnum(evm.Opcode.PUSH1), 100,
        @intFromEnum(evm.Opcode.PUSH1), 35,
        @intFromEnum(evm.Opcode.MSTORE8),
        @intFromEnum(evm.Opcode.PUSH1), 4,
        @intFromEnum(evm.Opcode.MLOAD),
    };

    var evm_interp = try evm.Interpreter.init(allocator, bytecode);
    defer evm_interp.deinit();

    try evm.execute(&evm_interp);
    try evm_interp.prettyPrint();

    const decompiled_bytecode = try evm.decompile(allocator, bytecode);
    defer allocator.free(decompiled_bytecode);
    utils.printBoxed("Decompiled Bytecode", decompiled_bytecode);
}

// TODO: rename operands in instruction definitions
// TODO: implement merkle patricia trie instead of hashmap and serialize/deserialize it to/from file
// TODO: transactions to storage should be recorded and committed only once only on success
