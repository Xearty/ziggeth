const std = @import("std");
const evm = @import("evm");
const utils = @import("evm_utils");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const bytecode: []const u8 = &.{
        @intFromEnum(evm.Opcode.PUSH1), 48,
        @intFromEnum(evm.Opcode.PUSH1), 0x00,
        @intFromEnum(evm.Opcode.MSTORE8),
        @intFromEnum(evm.Opcode.PUSH1), 0x02,
        @intFromEnum(evm.Opcode.PUSH1), 0x00,
        @intFromEnum(evm.Opcode.SHA3),
    };

    var volatile_host = evm.VolatileHost.init(allocator);
    defer volatile_host.deinit();

    var evm_host = volatile_host.host();

    var evm_interp = try evm.Interpreter.init(allocator, &evm_host, bytecode);
    defer evm_interp.deinit();
    try evm.execute(&evm_interp);

    try volatile_host.storage.prettyPrint();
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
// TODO: storage operations should take contract address from the environment
// TODO: Think of Host errors that can happen and complete the Host functions return types
