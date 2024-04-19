const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Word = @import("types").Word;
const Contract = @import("types").Contract;
const Transaction = @import("types").Transaction;
const Stack = @import("stack.zig").Stack;
const Host = @import("Host.zig");
const Memory = @import("Memory.zig");
const instructions = @import("evm_instructions");
const opcodes = instructions.opcodes;
const Opcode = opcodes.Opcode;
const utils = @import("evm_utils");

const Interpreter = @This();
const StackType = Stack(Word);

frames: Stack(Frame),
stack: StackType,
memory: Memory,
host: *Host,
status: VMStatus,
return_data: ?[]const u8,
allocator: Allocator,

pub fn init(allocator: Allocator, host: *Host) !Interpreter {
    return .{
        .frames = Stack(Frame).init(allocator),
        .stack = StackType.init(allocator),
        .memory = try Memory.init(allocator),
        .host = host,
        .status = .RUNNING,
        .return_data = null,
        .allocator = allocator,
    };
}

pub fn deinit(self: *Interpreter) void {
    self.stack.deinit();
    self.memory.deinit();
    self.frames.deinit();
    if (self.return_data) |memory| self.allocator.free(memory);
}

pub fn execute(self: *Interpreter, tx: Transaction) !?[]const u8 {
    const account = self.host.getAccount(tx.to).?;
    const contract = switch (account) {
        .contract => |contract| contract,
        .eoa => |_| unreachable,
    };

    const base_frame = Frame {
        .executing_contract = contract,
        .program_counter = 0,
        .status = .Executing,
    };
    try self.frames.push(base_frame);

    while (self.status == .RUNNING) {
        const frame = self.frames.top().?;
        const code = frame.executing_contract.code;
        const program_counter = frame.program_counter;
        const opcode = opcodes.fromByte(code[program_counter]);

        self.advanceProgramCounter(instructions.getSize(opcode));
        try self.executeInstruction(opcode);

        if (frame.status == .Returned) {
            _ = self.frames.pop();
            if (self.frames.size() == 1) {
                self.status = .HALTED;
            }
        }
    }

    return self.return_data;
}

pub fn setReturnData(self: *Interpreter, data: []const u8) !void {
    if (self.return_data) |memory| self.allocator.free(memory);
    self.return_data = try self.allocator.dupe(u8, data);
}

pub fn clearReturnData(self: *Interpreter) void {
    if (self.return_data) |memory| self.allocator.free(memory);
    self.return_data = null;
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
    var frame = self.frames.top().?;
    frame.program_counter += leap;
    if (frame.program_counter >= frame.executing_contract.code.len) {
        self.status = .HALTED;
    }
}

const Frame = struct {
    executing_contract: Contract,
    program_counter: usize,
    status: FrameStatus,
};

pub const FrameStatus = enum {
    Executing,
    Returned,
};

 // TODO: impl RETURNED state and stick it in frame
pub const VMStatus = enum {
    RUNNING,
    HALTED,
    RETURNED,
};

