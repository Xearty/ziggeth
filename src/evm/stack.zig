const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const printBoxed = @import("evm_utils").printBoxed;

pub fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();
        const InnerType = ArrayList(T);

        inner: InnerType,

        pub fn init(allocator: Allocator) Self {
            return .{
                .inner = InnerType.init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.inner.deinit();
        }

        pub fn peek(self: *Self) ?T {
            return self.inner.getLastOrNull();
        }

        pub fn top(self: *Self) ?*T {
            if (self.inner.items.len == 0) return null;
            return &self.inner.items[self.inner.items.len - 1];
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

        pub fn prettyPrint(self: *const Self) !void {
            var buffer: [1024]u8 = undefined;
            const format = "{}";
            var message = std.ArrayList(u8).init(self.inner.allocator);
            defer message.deinit();

            for (self.inner.items) |item| {
                const line = try std.fmt.bufPrint(&buffer, format, .{item});
                try message.appendSlice(line);
                try message.append('\n');
            }

            _ = message.popOrNull();
            printBoxed("Stack", message.items);
        }
    };
}
