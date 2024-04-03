const std = @import("std");
const opcodes = @import("opcodes.zig");
const Word = @import("constants.zig").Word;
const meta = @import("meta.zig");
const utils = @import("utils.zig");

pub const Instruction = meta.Instruction;
pub const getInstructionSize = meta.getInstructionSize;

pub fn decode(bytecode_stream: []const u8) !Instruction {
    const opcode = opcodes.fromByte(bytecode_stream[0]);
    const stack_input = bytecode_stream[1..];
    return switch (opcode) {
        inline else => |tag| blk: {
            if (comptime isQuantifiedInstruction(tag, "PUSH")) |count| {
                const value = utils.wordFromBigEndianBytes(stack_input[0..count]);
                break :blk @unionInit(Instruction, @tagName(tag), .{ .value = value });
            }
            break :blk @field(Instruction, @tagName(tag));
        },
    };
}

fn isQuantifiedInstruction(comptime tag: opcodes.Opcode, comptime prefix: []const u8) ?u32 {
    if (comptime std.mem.startsWith(u8, @tagName(tag), prefix)) {
        return std.fmt.parseInt(u32, @tagName(tag)[prefix.len..], 10) catch unreachable;
    }
    return null;
}