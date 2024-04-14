const std = @import("std");
const constants = @import("constants");
const Word = constants.Word;
const Address = constants.Address;
const Storage = @import("Storage.zig");

const Self = @This();

pub const HostVTable = struct {
    sstore: *const fn(ctx: *anyopaque, key: Word, value: Word) void,
    sload: *const fn(ctx: *anyopaque, key: Word) ?Word,
    get_contract_code: *const fn(ctx: *anyopaque, address: Address) ?[]const u8,
    deploy_contract: *const fn(ctx: *anyopaque, code: []const u8) ?Address,
};

ptr: *anyopaque,
vtable: *const HostVTable,

pub fn sstore(self: *Self, key: Word, value: Word) void {
    self.vtable.sstore(self.ptr, key, value);
}

pub fn sload(self: *Self, key: Word) ?Word {
    return self.vtable.sload(self.ptr, key);
}

pub fn getContractCode(self: *Self, address: Address) ?[]const u8 {
    return self.vtable.get_contract_code(self.ptr, address);
}

pub fn deployContract(self: *Self, code: []const u8) ?Address {
    return self.vtable.deploy_contract(self.ptr, code);
}

