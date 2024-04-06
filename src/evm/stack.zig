const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

pub fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();
        const InnerType = ArrayList(T);

        inner: InnerType,

        pub fn init(allocator: Allocator) Self {
            return Self {
                .inner = InnerType.init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.inner.deinit();
        }

        pub fn peek(self: *Self) ?T {
            return self.inner.getLastOrNull();
        }

        pub fn push(self: *Self, value: T) !void {
            try self.inner.append(value);
        }

        pub fn pop(self: *Self) T {
            return self.inner.pop();
        }

        pub fn dup(self: *Self, offset: usize) !void {
            const length = self.inner.items.len;
            const dupped = self.inner.items[length - offset];
            try self.inner.append(dupped);
        }

        pub fn swap(self: *Self, offset: usize) !void {
            const length = self.inner.items.len;
            const swapped = self.inner.swapRemove(length - offset - 1);
            try self.inner.append(swapped);
        }
    };
}
