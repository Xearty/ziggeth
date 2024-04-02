
const std = @import("std");
const Allocator = std.mem.Allocator;
const Stack = std.ArrayList(u8);

pub const Context = struct {
    program_counter: usize,
    stack: Stack,
    allocator: Allocator,

    const Self = @This();

    pub fn init(allocator: Allocator) Self {
        return .{
            .program_counter = 0,
            .stack = Stack.init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        self.stack.deinit();
    }
};