const std = @import("std");
const Allocator = std.mem.Allocator;
const Host = @import("Host.zig");
const utils = @import("evm_utils");
const types = @import("types");
const Word = types.Word;
const Address = types.Address;
const WorldState = types.WorldState;
const Account = types.Account;
const Contract = types.Contract;
const Storage = @import("Storage.zig");

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
    std.os.getrandom(&random_bytes) catch unreachable;
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

