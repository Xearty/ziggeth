const std = @import("std");
const opcodes = @import("opcodes.zig");
const Word = @import("constants.zig").Word;
const meta = @import("meta.zig");
const utils = @import("utils.zig");

pub const Instruction = meta.Instruction;
pub const getInstructionSize = meta.getInstructionSize;

pub fn decode(bytecode_stream: []const u8) Instruction {
    const opcode = opcodes.fromByte(bytecode_stream[0]);
    const stack_input = bytecode_stream[1..];
    return switch (opcode) {
        .PUSH1 => Instruction{ .PUSH1 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..1]) } },
        .PUSH2 => Instruction{ .PUSH2 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..2]) } },
        .PUSH3 => Instruction{ .PUSH3 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..3]) } },
        inline else => |tag| @field(Instruction, @tagName(tag)),
    };
}
