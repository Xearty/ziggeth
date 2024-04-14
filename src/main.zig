const std = @import("std");
const assert = std.debug.assert;
const ArrayList = std.ArrayList;
const evm = @import("evm");
const utils = @import("evm_utils");
const rlp = evm.rlp;
const constants = @import("constants");
const Address = constants.Address;

fn deployTestContract(host: *evm.Host) Address {
    const bytecode: []const u8 = &.{
        @intFromEnum(evm.Opcode.PUSH1), 48,
        @intFromEnum(evm.Opcode.PUSH1), 0x00,
        @intFromEnum(evm.Opcode.MSTORE8),
        @intFromEnum(evm.Opcode.PUSH1), 0x02,
        @intFromEnum(evm.Opcode.PUSH1), 0x00,
        @intFromEnum(evm.Opcode.SHA3),
        @intFromEnum(evm.Opcode.CODESIZE),
        @intFromEnum(evm.Opcode.PUSH1), 1,
        @intFromEnum(evm.Opcode.ADD),
        @intFromEnum(evm.Opcode.PUSH1), 0x00,
        @intFromEnum(evm.Opcode.PUSH1), 0x00,
        @intFromEnum(evm.Opcode.CODECOPY),
    };

    return host.deployContract(bytecode).?;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();


    var volatile_host = evm.VolatileHost.init(allocator);
    defer volatile_host.deinit();

    var evm_host = volatile_host.host();

    const contract_address = deployTestContract(&evm_host);
    const bytecode = evm_host.getContractCode(contract_address).?;

    var evm_interp = try evm.Interpreter.init(allocator, &evm_host, bytecode);
    defer evm_interp.deinit();
    try evm_interp.execute();

    try volatile_host.storage.prettyPrint();
    try evm_interp.prettyPrint();

    const decompiled_bytecode = try evm.decompile(allocator, bytecode);
    defer allocator.free(decompiled_bytecode);
    utils.printBoxed("Decompiled Bytecode", decompiled_bytecode);
    for (bytecode) |byte| {
        std.debug.print("0x{x}, ", .{byte});
    }
}

// TODO: rename operands in instruction definitions
// TODO: implement merkle patricia trie instead of hashmap and serialize/deserialize it to/from file
// TODO: transactions to storage should be recorded and committed only once only on success
// TODO: use a stack of memory in the interpreter. When a contract is called from within a contract
// the memory of the parent contract is saved and restored after the child contract's execution is complete
// TODO: storage operations should take contract address from the environment
// TODO: Think of Host errors that can happen and complete the Host functions return types
// TODO: implement transaction validation
// TODO: meta program to serialize and deserialize a zig struct that tries to guess the size and sets
// the inital capacity of the ArrayList buffer
// TODO: use fixed buffers for rlp encoding
