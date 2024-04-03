const std = @import("std");
const opcodes = @import("opcodes.zig");
const Word = @import("constants.zig").Word;
const meta = @import("meta.zig");

pub const Instruction = meta.Instruction;
pub const getInstructionSize = meta.getInstructionSize;

pub fn decode(bytecode_stream: []const u8) Instruction {
    const opcode = opcodes.fromByte(bytecode_stream[0]);
    return switch (opcode) {
        .PUSH1 => Instruction{ .PUSH1 = .{ .value = bytecode_stream[1] } },
        inline else => |tag| @field(Instruction, @tagName(tag)),
    };
}
