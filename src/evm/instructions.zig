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
            if (comptime std.mem.startsWith(u8, @tagName(tag), "PUSH")) {
                const bytes_count = try std.fmt.parseInt(u32, @tagName(tag)["PUSH".len..], 10);
                break :blk @unionInit(Instruction, @tagName(tag), .{ .value = utils.wordFromBigEndianBytes(stack_input[0..bytes_count]) });
            }
            break :blk @field(Instruction, @tagName(tag));
        },
    };
}
