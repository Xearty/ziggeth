const std = @import("std");
const Allocator = std.mem.Allocator;
const Stack = std.ArrayList;

const Word = @import("constants.zig").Word;

pub const Context = struct {
    program_counter: usize,
    stack: Stack(Word),
    is_halted: bool,
    allocator: Allocator,

    const Self = @This();

    pub fn init(allocator: Allocator) Self {
        return .{
            .program_counter = 0,
            .stack = Stack(Word).init(allocator),
            .is_halted = false,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        self.stack.deinit();
    }
};