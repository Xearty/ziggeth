const std = @import("std");
const Allocator = std.mem.Allocator;
const evm = @import("./evm/evm.zig");
const eth_types = @import("eth_types");
const Transaction = eth_types.Transaction;
const Address = eth_types.Address;

pub fn deployContract(allocator: Allocator, host: *evm.Host, tx: Transaction) !Address {
    std.debug.assert(tx.to == 0);

    var interpreter = try evm.Interpreter.init(allocator, host);
    defer interpreter.deinit();

    const bytecode = try interpreter.execute(tx);
    return host.deployContract(allocator, bytecode.?).?;
}
