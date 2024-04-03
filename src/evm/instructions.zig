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
        .PUSH4 => Instruction{ .PUSH4 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..4]) } },
        .PUSH5 => Instruction{ .PUSH5 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..5]) } },
        .PUSH6 => Instruction{ .PUSH6 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..6]) } },
        .PUSH7 => Instruction{ .PUSH7 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..7]) } },
        .PUSH8 => Instruction{ .PUSH8 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..8]) } },
        .PUSH9 => Instruction{ .PUSH9 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..9]) } },
        .PUSH10 => Instruction{ .PUSH10 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..10]) } },
        .PUSH11 => Instruction{ .PUSH11 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..11]) } },
        .PUSH12 => Instruction{ .PUSH12 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..12]) } },
        .PUSH13 => Instruction{ .PUSH13 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..13]) } },
        .PUSH14 => Instruction{ .PUSH14 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..14]) } },
        .PUSH15 => Instruction{ .PUSH15 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..15]) } },
        .PUSH16 => Instruction{ .PUSH16 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..16]) } },
        .PUSH17 => Instruction{ .PUSH17 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..17]) } },
        .PUSH18 => Instruction{ .PUSH18 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..18]) } },
        .PUSH19 => Instruction{ .PUSH19 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..19]) } },
        .PUSH20 => Instruction{ .PUSH20 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..20]) } },
        .PUSH21 => Instruction{ .PUSH21 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..21]) } },
        .PUSH22 => Instruction{ .PUSH22 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..22]) } },
        .PUSH23 => Instruction{ .PUSH23 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..23]) } },
        .PUSH24 => Instruction{ .PUSH24 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..24]) } },
        .PUSH25 => Instruction{ .PUSH25 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..25]) } },
        .PUSH26 => Instruction{ .PUSH26 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..26]) } },
        .PUSH27 => Instruction{ .PUSH27 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..27]) } },
        .PUSH28 => Instruction{ .PUSH28 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..28]) } },
        .PUSH29 => Instruction{ .PUSH29 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..29]) } },
        .PUSH30 => Instruction{ .PUSH30 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..30]) } },
        .PUSH31 => Instruction{ .PUSH31 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..31]) } },
        .PUSH32 => Instruction{ .PUSH32 = .{ .value = utils.wordFromBigEndianBytes(stack_input[0..32]) } },
        inline else => |tag| @field(Instruction, @tagName(tag)),
    };
}
