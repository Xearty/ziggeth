const std = @import("std");
const Allocator = std.mem.Allocator;
const Word = @import("constants").Word;
const Stack = @import("stack.zig").Stack;
const Storage = @import("storage.zig").Storage;

pub const Context = struct {
    const Self = @This();
    const StackType = Stack(Word);
    const StorageType = Storage(Word, Word);

    program_counter: usize,
    bytecode: []const u8,
    stack: StackType,
    storage: StorageType,
    status: VMStatus,
    allocator: Allocator,

    pub fn init(allocator: Allocator, bytecode: []const u8) Self {
        return .{
            .program_counter = 0,
            .bytecode = bytecode,
            .stack = StackType.init(allocator),
            .storage = StorageType.init(allocator),
            .status = .RUNNING,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        self.stack.deinit();
        self.storage.deinit();
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

