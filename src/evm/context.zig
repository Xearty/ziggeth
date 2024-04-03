const std = @import("std");
const Allocator = std.mem.Allocator;
const Stack = std.ArrayList;

const WordType = @import("constants.zig").WordType;

pub const Context = struct {
    program_counter: usize,
    stack: Stack(WordType),
    is_halted: bool,
    allocator: Allocator,

    const Self = @This();

    pub fn init(allocator: Allocator) Self {
        return .{
            .program_counter = 0,
            .stack = Stack(WordType).init(allocator),
            .is_halted = false,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        self.stack.deinit();
    }

    pub fn peek(self: *const Self) ?u256 {
        return self.stack.getLastOrNull();
    }
};