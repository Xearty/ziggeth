const std = @import("std");
const ArrayList = std.ArrayList;
const evm = @import("evm");
const utils = @import("evm_utils");
const rlp = evm.rlp;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var inner = rlp.ListBuilder.init(allocator);
    try inner.appendString("hello");
    try inner.appendString("there");

    var outer = rlp.ListBuilder.init(allocator);
    defer outer.deinit();
    try inner.appendString("I am inside");
    try outer.appendList(inner.list);
    try outer.appendString("I am outside");

    var bytes = ArrayList(u8).init(allocator);
    _ = try outer.list.encode(&bytes);
    std.debug.print("bytes: {any}\n", .{bytes.items});

    outer.print();

    // const bytecode: []const u8 = &.{
    //     @intFromEnum(evm.Opcode.PUSH1), 48,
    //     @intFromEnum(evm.Opcode.PUSH1), 0x00,
    //     @intFromEnum(evm.Opcode.MSTORE8),
    //     @intFromEnum(evm.Opcode.PUSH1), 0x02,
    //     @intFromEnum(evm.Opcode.PUSH1), 0x00,
    //     @intFromEnum(evm.Opcode.SHA3),
    // };
    //
    // var volatile_host = evm.VolatileHost.init(allocator);
    // defer volatile_host.deinit();
    //
    // var evm_host = volatile_host.host();
    //
    // var evm_interp = try evm.Interpreter.init(allocator, &evm_host, bytecode);
    // defer evm_interp.deinit();
    // try evm_interp.execute();
    //
    // try volatile_host.storage.prettyPrint();
    // try evm_interp.prettyPrint();
    //
    // const decompiled_bytecode = try evm.decompile(allocator, bytecode);
    // defer allocator.free(decompiled_bytecode);
    // utils.printBoxed("Decompiled Bytecode", decompiled_bytecode);
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
