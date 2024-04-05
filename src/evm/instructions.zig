const std = @import("std");
const opcodes = @import("opcodes.zig");
const Word = @import("constants").Word;
const meta = @import("meta");
const utils = @import("utils.zig");

pub const Instruction = meta.Instruction;

pub fn decode(bytecode_stream: []const u8) !Instruction {
    const opcode = opcodes.fromByte(bytecode_stream[0]);
    const stack_input = bytecode_stream[1..];
    return switch (opcode) {
        inline else => |tag| blk: {
            if (comptime isQuantified(tag, "PUSH")) |count| {
                const value = utils.wordFromBigEndianBytes(stack_input[0..count]);
                break :blk @unionInit(Instruction, @tagName(tag), .{ .value = value });
            }
            break :blk @field(Instruction, @tagName(tag));
        },
    };
}

pub fn isQuantified(comptime opcode: opcodes.Opcode, comptime prefix: []const u8) ?u32 {
    if (comptime std.mem.startsWith(u8, @tagName(opcode), prefix)) {
        return std.fmt.parseInt(u32, @tagName(opcode)[prefix.len..], 10) catch unreachable;
    }
    return null;
}

pub fn getSize(opcode: opcodes.Opcode) usize {
    return switch (opcode) {
        inline else => |tag| blk: {
            inline for (meta.instruction_definitions) |def| {
                @setEvalBranchQuota(10000);
                if (comptime @intFromEnum(tag) == def.opcode) {
                    break :blk def.size;
                }
            }
        },
    };
}
