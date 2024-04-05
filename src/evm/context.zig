const std = @import("std");
const Allocator = std.mem.Allocator;
const Word = @import("constants").Word;
const Stack = @import("stack.zig").Stack;

pub const Context = struct {
    program_counter: usize,
    bytecode: []const u8,
    stack: Stack(Word),
    status: VMStatus,
    allocator: Allocator,

    const Self = @This();

    pub fn init(allocator: Allocator, bytecode: []const u8) Self {
        return .{
            .program_counter = 0,
            .bytecode = bytecode,
            .stack = Stack(Word).init(allocator),
            .status = .RUNNING,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        self.stack.deinit();
    }

    pub fn advanceProgramCounter(self: *Self, leap: usize) void {
        self.program_counter += leap;
        if (self.program_counter >= self.bytecode.len) {
            self.status = .HALTED;
        }
    }
};

pub const VMStatus = enum {
    RUNNING,
    HALTED,
};

