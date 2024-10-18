const std = @import("std");
const Allocator = std.mem.Allocator;
const Host = @import("Host.zig");
const utils = @import("utils");
const eth_types = @import("eth_types");
const Word = eth_types.Word;
const Address = eth_types.Address;
const WorldState = eth_types.WorldState;
const Account = eth_types.Account;
const Contract = eth_types.Contract;
const Storage = eth_types.Storage;

const Self = @This();

world_state: WorldState,

pub fn init(allocator: Allocator) Self {
    return .{
        .world_state = WorldState.init(allocator),
    };
}

pub fn deinit(self: *Self) void {
    self.world_state.deinit();
}

pub fn host(self: *Self) Host {
    return .{
        .ptr = self,
        .vtable = &.{
            .sstore = sstore,
            .sload = sload,
            .get_contract_code = getContractCode,
            .deploy_contract = deployContract,
            .get_account = getAccount,
        },
    };
}

fn sstore(ctx: *anyopaque, address: Address, key: Word, value: Word) void {
    const self: *Self = @ptrCast(@alignCast(ctx));
    var account = self.world_state.get(address).?;
    switch (account) {
        .contract => |*contract| contract.storage.store(key, value) catch unreachable,
        .eoa => |_| unreachable,
    }
}

fn sload(ctx: *anyopaque, address: Address, key: Word) ?Word {
    const self: *Self = @ptrCast(@alignCast(ctx));
    var account = self.world_state.get(address).?;
    switch (account) {
        .contract => |*contract| return contract.storage.load(key),
        .eoa => |_| unreachable,
    }
}

fn getContractCode(ctx: *anyopaque, address: Address) ?[]const u8 {
    const self: *Self = @ptrCast(@alignCast(ctx));
    const account = self.world_state.get(address).?;
    switch (account) {
        .contract => |contract| return contract.code,
        .eoa => |_| return null,
    }
}

fn getAccount(ctx: *anyopaque, address: Address) ?Account {
    const self: *Self = @ptrCast(@alignCast(ctx));
    return self.world_state.get(address);
}

// TODO: there must be init code
fn deployContract(ctx: *anyopaque, allocator: Allocator, code: []const u8) ?Address {
    const self: *Self = @ptrCast(@alignCast(ctx));
    var random_bytes: [@sizeOf(Address)]u8 = undefined;
    std.Random.bytes(std.crypto.random, &random_bytes);
    const address = utils.intFromBigEndianBytes(Address, &random_bytes);

    const contract = Account {
        .contract = .{
            .address = address,
            .balance = 0,
            .nonce = 0,
            .code = allocator.dupe(u8, code) catch unreachable,
            .storage = Storage.init(allocator),
        },
    };
    self.world_state.put(address, contract) catch unreachable;

    std.debug.print("Contract deployed at address {}\n", .{address});
    return address;
}

