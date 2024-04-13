const std = @import("std");
const Allocator = std.mem.Allocator;
const Host = @import("Host.zig");
const utils = @import("evm_utils");
const constants = @import("constants");
const Word = constants.Word;
const Address = constants.Address;
const Storage = @import("Storage.zig");

const Self = @This();
const ContractsMappingType = std.hash_map.AutoHashMap(Address, []const u8);

storage: Storage,
contracts: ContractsMappingType,


pub fn init(allocator: Allocator) Self {
    return .{
        .storage = Storage.init(allocator),
        .contracts = ContractsMappingType.init(allocator),
    };
}

pub fn deinit(self: *Self) void {
    self.storage.deinit();
}

pub fn host(self: *Self) Host {
    return .{
        .ptr = self,
        .vtable = &.{
            .sstore = sstore,
            .sload = sload,
            .get_contract_code = get_contract_code,
            .deploy_contract = deploy_contract,
        },
    };
}

fn sstore(ctx: *anyopaque, key: Word, value: Word) void {
    const self: *Self = @ptrCast(@alignCast(ctx));
    self.storage.store(key, value) catch unreachable;
}

fn sload(ctx: *anyopaque, key: Word) ?Word {
    const self: *Self = @ptrCast(@alignCast(ctx));
    return self.storage.load(key);
}

fn get_contract_code(ctx: *anyopaque, address: Address) ?[]const u8 {
    const self: *Self = @ptrCast(@alignCast(ctx));
    return self.contracts.get(address).?;
}

fn deploy_contract(ctx: *anyopaque, code: []const u8) ?Address {
    const self: *Self = @ptrCast(@alignCast(ctx));
    var random_bytes: [@sizeOf(Address)]u8 = undefined;
    std.os.getrandom(&random_bytes) catch unreachable;
    const address = utils.intFromBigEndianBytes(Address, &random_bytes);
    self.contracts.put(address, code) catch unreachable;

    std.debug.print("Contract deployed at address {}\n", .{address});
    return address;
}

