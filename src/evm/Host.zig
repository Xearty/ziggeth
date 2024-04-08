const std = @import("std");
const constants = @import("constants");
const Word = constants.Word;
const Storage = @import("storage.zig").Storage;

const Self = @This();

pub const HostVTable = struct {
    sstore: *const fn(ctx: *anyopaque, key: Word, value: Word) void,
    sload: *const fn(ctx: *anyopaque, key: Word) ?Word,
};

ptr: *anyopaque,
vtable: *const HostVTable,

pub fn sstore(self: *Self, key: Word, value: Word) void {
    self.vtable.sstore(self.ptr, key, value);
}

pub fn sload(self: *Self, key: Word) ?Word {
    return self.vtable.sload(self.ptr, key);
}
