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
            if (comptime isQuantifiedInstruction(@tagName(tag), "PUSH")) |count| {
                const value = utils.wordFromBigEndianBytes(stack_input[0..count]);
                break :blk @unionInit(Instruction, @tagName(tag), .{ .value = value });
            }
            break :blk @field(Instruction, @tagName(tag));
        },
    };
}

pub fn isQuantifiedInstruction(comptime tag_name: []const u8, comptime prefix: []const u8) ?u32 {
    if (comptime std.mem.startsWith(u8, tag_name, prefix)) {
        return std.fmt.parseInt(u32, tag_name[prefix.len..], 10) catch unreachable;
    }
    return null;
}