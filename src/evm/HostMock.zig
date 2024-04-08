const std = @import("std");
const Allocator = std.mem.Allocator;
const Host = @import("Host.zig");
const constants = @import("constants");
const Word = constants.Word;
const Storage = @import("storage.zig").Storage;

const Self = @This();
const StorageType = Storage(Word, Word);

storage: StorageType,

pub fn init(allocator: Allocator) Self {
    return .{
        .storage = StorageType.init(allocator),
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
