const std = @import("std");
const evm = @import("evm");
const utils = @import("evm_utils");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const bytecode: []const u8 = &.{
        @intFromEnum(evm.Opcode.PUSH1), 100,
        @intFromEnum(evm.Opcode.PUSH2), 0x01, 0xa1,
        @intFromEnum(evm.Opcode.MSTORE8),
        @intFromEnum(evm.Opcode.MSIZE),
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
// TODO: use a stack of memory in the interpreter. When a contract is called from within a contract
// the memory of the parent contract is saved and restored after the child contract's execution is complete
