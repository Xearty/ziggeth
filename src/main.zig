const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const ArrayList = std.ArrayList;
const evm = @import("evm");
const utils = @import("evm_utils");
const rlp = evm.rlp;
const types = @import("types");
const Address = types.Address;
const Transaction = types.Transaction;

fn hexCharacterToDecimal(hex_char: u8) u8 {
    if (hex_char >= '0' and hex_char <= '9') return hex_char - '0';
    if (hex_char >= 'a' and hex_char <= 'f') return hex_char - 'a' + 10;
    unreachable;
}

fn hexToBytesOwned(allocator: Allocator, hex_string: []const u8) ![]u8 {
    const bytes_count = hex_string.len / 2;
    var buffer = try allocator.alloc(u8, bytes_count);

    var offset: usize = 0;
    while (offset < bytes_count) : (offset += 1) {
        const first_char = hexCharacterToDecimal(hex_string[offset * 2]);
        const second_char = hexCharacterToDecimal(hex_string[offset * 2 + 1]);
        buffer[offset] = first_char * 16 + second_char;
    }

    return buffer;
}

fn deployTestContract(allocator: Allocator, host: *evm.Host) Address {
    const bytecode: []const u8 = &.{
        @intFromEnum(evm.Opcode.CALLDATASIZE),
        @intFromEnum(evm.Opcode.PUSH1), 0x00,
        @intFromEnum(evm.Opcode.PUSH1), 0x01,
        @intFromEnum(evm.Opcode.CALLDATACOPY),
    };

    return host.deployContract(allocator, bytecode).?;
}

fn deployContract(allocator: Allocator, host: *evm.Host, tx: Transaction) !Address {
    std.debug.assert(tx.to == 0);

    var evm_interp = try evm.Interpreter.init(allocator, host);
    defer evm_interp.deinit();

    const bytecode = try evm_interp.execute(tx);
    return evm_interp.host.deployContract(allocator, bytecode.?).?;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const bytecode_file = @embedFile("bytecode");
    const bytecode = try hexToBytesOwned(allocator, bytecode_file[0..bytecode_file.len-1]);
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

    const contract_address = try deployContract(allocator, &evm_host, contract_creation_transaction);

    const message_call_transaction = Transaction {
        .from = 69,
        .to = contract_address,
        .nonce = 1,
        .value = 0,
        // 17 * 5
        .data = try hexToBytesOwned(allocator, "eb8ac92100000000000000000000000000000000000000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000005"),
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
