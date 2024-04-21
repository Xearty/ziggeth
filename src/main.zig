const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const execution_engine = @import("execution_engine");
const evm = execution_engine.evm;
const system = execution_engine.system;

const utils = @import("utils");
const eth_types = @import("eth_types");
const Address = eth_types.Address;
const Transaction = eth_types.Transaction;
const BinaryBufferBuilder = utils.BinaryBufferBuilder;

fn deployTestContract(allocator: Allocator, host: *evm.Host) Address {
    const bytecode: []const u8 = &.{
        @intFromEnum(evm.Opcode.CALLDATASIZE),
        @intFromEnum(evm.Opcode.PUSH1), 0x00,
        @intFromEnum(evm.Opcode.PUSH1), 0x01,
        @intFromEnum(evm.Opcode.CALLDATACOPY),
    };

    return host.deployContract(allocator, bytecode).?;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const bytecode_file = @embedFile("./execution_engine/solidity/out/Test.bin");
    const bytecode = try utils.hexToBytesOwned(allocator, bytecode_file);
    defer allocator.free(bytecode);

    var volatile_host = evm.VolatileHost.init(allocator);
    defer volatile_host.deinit();

    var evm_host = volatile_host.host();

    const contract_creation_transaction = Transaction {
        .from = 69,
        .to = 0,
        .nonce = 0,
        .value = 0,
        .data = bytecode,
    };

    const contract_address = try system.deployContract(allocator,&evm_host, contract_creation_transaction);

    const signature = "test(uint256,uint256)";
    const selector = utils.computeFunctionSelector(signature);

    var call_data_builder = BinaryBufferBuilder.init(allocator);
    try call_data_builder.appendInt(u32, selector);
    try call_data_builder.appendInt(u256, 3);
    try call_data_builder.appendInt(u256, 5);

    const message_call_transaction = Transaction {
        .from = 69,
        .to = contract_address,
        .nonce = 1,
        .value = 0,
        .data = try call_data_builder.toOwned(),
    };
    var evm_interp = try evm.Interpreter.init(allocator, &evm_host);
    defer evm_interp.deinit();

    const returned_bytes = try evm_interp.execute(message_call_transaction);
    std.debug.print("final return: {any}\n", .{returned_bytes});

    // try volatile_host.storage.prettyPrint();
    try evm_interp.prettyPrint();
    // std.debug.print("program_counter: {}", .{evm_interp.program_counter});

    // const decompiled_bytecode = try evm.decompile(allocator, stripped_bytecode);
    // defer allocator.free(decompiled_bytecode);
    // utils.printBoxed("Decompiled Bytecode", decompiled_bytecode);

    // for (bytecode) |byte| {
    //     std.debug.print("0x{x}, ", .{byte});
    // }
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
// TODO: generate zig structs for test contracts from ABI
