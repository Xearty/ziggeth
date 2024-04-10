const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

pub const List = struct {
    inner: ArrayList(Item),

    pub fn init(allocator: Allocator) List {
        return .{
            .inner = ArrayList(Item).init(allocator),
        };
    }

    pub fn deinit(self: *List) void {
        for (self.inner.items) |*item| {
            item.deinit();
        }
        self.inner.deinit();
    }

    pub fn print(self: *const List) void {
        if (self.inner.items.len == 0) {
            std.debug.print("[]", .{});
            return;
        }

        std.debug.print("[", .{});
        self.inner.items[0].print();

        for (1..self.inner.items.len) |index| {
            std.debug.print(", ", .{});
            self.inner.items[index].print();
        }
        std.debug.print("]", .{});
    }
};

pub const String = struct {
    data: []u8,
    allocator: Allocator,

    pub fn init(allocator: Allocator, data: []const u8) !String {
        return .{
            .data = try allocator.dupe(u8, data),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *String) void {
        self.allocator.free(self.data);
    }

    pub fn print(self: *const String) void {
        std.debug.print("\"{s}\"", .{self.data});
    }
};

pub const Item = union(enum) {
    string: String,
    list: List,

    pub fn deinit(self: *Item) void {
        switch (self.*) {
            .string => |*string| string.deinit(),
            .list => |*list| list.deinit(),
        }
    }

    pub fn print(self: *const Item) void {
        switch (self.*) {
            .string => |string| string.print(),
            .list => |list| list.print(),
        }
    }
};

pub const ListBuilder = struct {
    list: List,
    allocator: Allocator,

    pub fn init(allocator: Allocator) ListBuilder {
        return .{
            .list = List.init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *ListBuilder) void {
        self.list.deinit();
    }

    pub fn appendString(self: *ListBuilder, data: []const u8) !void {
        const item = try String.init(self.allocator, data);
        try self.list.inner.append(.{ .string = item });
    }

    pub fn appendList(self: *ListBuilder, list: List) !void {
        try self.list.inner.append(.{ .list = list });
    }

    pub fn print(self: *const ListBuilder) void {
        self.list.print();
    }
};
