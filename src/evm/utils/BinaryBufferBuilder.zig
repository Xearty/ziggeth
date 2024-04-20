// NOTE: This is a big endian binary buffer builder

const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const utils = @import("root.zig");

const BinaryBufferBuilder = @This();

inner: ArrayList(u8),

pub fn init(allocator: Allocator) BinaryBufferBuilder {
    return .{
        .inner = ArrayList(u8).init(allocator),
    };
}

pub fn deinit(self: *BinaryBufferBuilder) void {
    self.inner.deinit();
}

pub fn appendInt(self: *BinaryBufferBuilder, comptime T: type, integer: T) !void {
    const bytes = utils.bigEndianBytesFromInt(T, integer);
    try self.inner.appendSlice(&bytes);
}

pub fn appendBytes(self: *BinaryBufferBuilder, bytes: []const u8) !void {
    try self.inner.appendSlice(bytes);
}

pub fn toOwned(self: *BinaryBufferBuilder) ![]u8 {
    return self.inner.toOwnedSlice();
}


