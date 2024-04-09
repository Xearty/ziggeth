const std = @import("std");
const Allocator = std.mem.Allocator;
const Word = @import("constants").Word;
const Stack = @import("stack.zig").Stack;
const Host = @import("Host.zig");
const Memory = @import("Memory.zig");
const instructions = @import("evm_instructions");
const opcodes = instructions.opcodes;
const Opcode = opcodes.Opcode;
const utils = @import("evm_utils");

const Interpreter = @This();
const StackType = Stack(Word);

program_counter: usize,
bytecode: []const u8,
stack: StackType,
memory: Memory,
host: *Host,
status: VMStatus,
allocator: Allocator,

pub fn init(allocator: Allocator, host: *Host, bytecode: []const u8) !Interpreter {
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

pub fn deinit(self: *Interpreter) void {
    self.stack.deinit();
    self.memory.deinit();
}

pub fn execute(self: *Interpreter) !void {
    while (self.status == .RUNNING) {
        const opcode = opcodes.fromByte(self.bytecode[self.program_counter]);
        self.advanceProgramCounter(instructions.getSize(opcode));
        try self.executeInstruction(opcode);
    }
}

pub fn prettyPrint(self: *const Interpreter) !void {
    try self.stack.prettyPrint();
    try self.memory.prettyPrint();
}

fn executeInstruction(self: *Interpreter, opcode: Opcode) !void {
    @setEvalBranchQuota(10000);
    switch (opcode) {
        inline else => |tag| {
            if (comptime instructions.isQuantified(tag)) |unquantified_tag| {
                const quantity = comptime instructions.extractQuantity(tag);
                try @field(instructions, utils.toLower(unquantified_tag))(self, quantity);
            } else {
                const function = comptime utils.toLower(@tagName(tag));
                try @field(instructions, function)(self);
            }
        }
    }
}

fn advanceProgramCounter(self: *Interpreter, leap: usize) void {
    self.program_counter += leap;
    if (self.program_counter >= self.bytecode.len) {
        self.status = .HALTED;
    }
}
pub const VMStatus = enum {
    RUNNING,
    HALTED,
};

