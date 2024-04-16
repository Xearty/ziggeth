const std = @import("std");
const Allocator = std.mem.Allocator;
const types = @import("types");
const Word = types.Word;
const Address = types.Address;
const Account = types.Account;
const Storage = @import("Storage.zig");

const Self = @This();

pub const HostVTable = struct {
    sstore: *const fn(ctx: *anyopaque, address: Address, key: Word, value: Word) void,
    sload: *const fn(ctx: *anyopaque, address: Address, key: Word) ?Word,
    get_contract_code: *const fn(ctx: *anyopaque, address: Address) ?[]const u8,
    deploy_contract: *const fn(ctx: *anyopaque, allocator: Allocator, code: []const u8) ?Address,
    get_account: *const fn(ctx: *anyopaque, address: Address) ?Account,
};

ptr: *anyopaque,
vtable: *const HostVTable,

pub fn sstore(self: *Self, address: Address, key: Word, value: Word) void {
    self.vtable.sstore(self.ptr, address, key, value);
}

pub fn sload(self: *Self, address: Address, key: Word) ?Word {
    return self.vtable.sload(self.ptr, address, key);
}

pub fn getContractCode(self: *Self, address: Address) ?[]const u8 {
    return self.vtable.get_contract_code(self.ptr, address);
}

pub fn deployContract(self: *Self, allocator: Allocator, code: []const u8) ?Address {
    return self.vtable.deploy_contract(self.ptr, allocator, code);
}

pub fn getAccount(self: *Self, address: Address) ?Account {
    return self.vtable.get_account(self.ptr, address);
}
