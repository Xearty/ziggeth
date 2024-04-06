const std = @import("std");
const AutoHashMap = std.AutoHashMap;
const Allocator = std.mem.Allocator;

pub fn Storage(comptime K: type, comptime V: type) type {
    return struct {
        const Self = @This();
        const InnerType = AutoHashMap(K, V);

        inner: InnerType,

        pub fn init(allocator: Allocator) Self {
            return Self {
                .inner = InnerType.init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.inner.deinit();
        }

        pub fn store(self: *Self, key: K, value: V) !void {
            try self.inner.put(key, value);
        }

        pub fn load(self: *Self, key: K) ?V {
            return self.inner.get(key);
        }
    };
}
