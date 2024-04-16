const std = @import("std");
const Storage = @import("../Storage.zig");

pub const Word = u256;
pub const SignedWord = i256;
pub const Address = u160;
pub const Gwei = u64;
pub const Wei = u64;
pub const Gas = u64;

pub const MessageCall = struct {
    sender: Address,
    transaction_originator: Address,
    recipient: Address,
    account: Address,
    value: Gwei,
    effective_gas_price: Gwei,
    data: []const u8,
    call_depth: u64,
    state_modification_permission: bool,
};

pub const ExternallyOwnedAccount = struct {
    address: Address,
    balance: Wei,
    nonce: u64,
};

pub const Contract = struct {
    address: Address,
    balance: Wei,
    nonce: u64,
    code: []const u8,
    storage: Storage
};

pub const Account = union(enum) {
    eoa: ExternallyOwnedAccount,
    contract: Contract,
};

pub const Transaction = struct {
    from: Address,
    to: Address,
    // signature: u256,
    nonce: u64,
    value: Wei,
    data: []const u8,
    // gas_limit: Gas,
    // max_fee_per_gas: Wei,
    // max_priority_fee_per_gas: Wei,
};

pub const WorldState = std.hash_map.AutoHashMap(Address, Account);
