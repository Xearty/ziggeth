const std = @import("std");
const Allocator = std.mem.Allocator;
const Word = @import("constants").Word;
const Stack = @import("stack.zig").Stack;
const Host = @import("Host.zig");
const Memory = @import("Memory.zig");

const Self = @This();
const StackType = Stack(Word);

program_counter: usize,
bytecode: []const u8,
stack: StackType,
memory: Memory,
host: *Host,
status: VMStatus,
allocator: Allocator,

pub fn init(allocator: Allocator, host: *Host, bytecode: []const u8) !Self {
    return .{
        .program_counter = 0,
        .bytecode = bytecode,
        .stack = StackType.init(allocator),
        .memory = try Memory.init(allocator),
        .host = host,
        .status = .RUNNING,
        .allocator = allocator,
    };
}

pub fn deinit(self: *Self) void {
    self.stack.deinit();
    self.memory.deinit();
}

pub fn advanceProgramCounter(self: *Self, leap: usize) void {
    self.program_counter += leap;
    if (self.program_counter >= self.bytecode.len) {
        self.status = .HALTED;
    }
}

pub fn prettyPrint(self: *const Self) !void {
    try self.stack.prettyPrint();
    try self.memory.prettyPrint();
}

pub const VMStatus = enum {
    RUNNING,
    HALTED,
};

