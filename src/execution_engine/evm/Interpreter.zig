const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

const eth_types = @import("eth_types");
const Storage = eth_types.Storage;
const Word = eth_types.Word;
const Contract = eth_types.Contract;
const Transaction = eth_types.Transaction;

const Stack = @import("common_dst").Stack;
const Host = @import("Host.zig");
const Memory = @import("Memory.zig");
const instructions = @import("./instructions/instructions.zig");
const opcodes = instructions.opcodes;
const Opcode = opcodes.Opcode;
const utils = @import("utils");

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
        .status = .Running,
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
    const base_frame = self.frameFromTransaction(tx);
    return try self.executeFrame(base_frame);
}

fn executeFrame(self: *Interpreter, base_frame: Frame) !?[]const u8 {
    try self.frames.push(base_frame);

    while (self.status == .Running) {
        const frame = self.frames.top().?;
        const code = frame.executing_contract.code;
        const program_counter = frame.program_counter;
        const opcode = opcodes.fromByte(code[program_counter]);

        self.advanceProgramCounter(instructions.getSize(opcode));
        try self.executeInstruction(opcode);

        if (frame.status == .Returned) {
            _ = self.frames.pop();
            if (self.frames.size() == 0) {
                self.status = .Halted;
            }
        }
    }

    return self.return_data;
}

fn initDummyContractWithCode(allocator: Allocator, code: []const u8) Contract {
    return .{
        .address = 0,
        .balance = 0,
        .nonce = 0,
        .code = code,
        .storage = Storage.init(allocator),
    };
}

fn frameFromTransaction(self: *const Interpreter, tx: Transaction) Frame {
    return switch (tx.to) {
        0 => .{
            .executing_contract = initDummyContractWithCode(self.allocator, tx.data),
            .program_counter = 0,
            .status = .Executing,
            .call_data = tx.data,
            .call_value = tx.value,
        },
        else => blk: {
            const account = self.host.getAccount(tx.to).?;
            const contract = switch (account) {
                .contract => |contract| contract,
                .eoa => |_| unreachable,
            };
            break :blk .{
                .executing_contract = contract,
                .program_counter = 0,
                .status = .Executing,
                .call_data = tx.data,
                .call_value = tx.value,
            };
        }
    };
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
        self.status = .Halted;
    }
}

const Frame = struct {
    executing_contract: Contract,
    program_counter: usize,
    status: FrameStatus,
    call_data: []const u8,
    call_value: u64,
};

pub const FrameStatus = enum {
    Executing,
    Returned,
};

pub const VMStatus = enum {
    Running,
    Halted,
    Returned,
};

