const std = @import("std");
const Word = @import("constants.zig").Word;

pub const Opcode = defineOpcodes();
pub const Instruction = defineInstructions();

const InstructionDefinition = struct {
    mnemonic: []const u8,
    opcode: u8,
    size: usize,
    payload_type: type,
};

const instruction_definitions: []const InstructionDefinition = &.{
    .{
        .mnemonic = "STOP",
        .opcode = 0x00,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "ADD",
        .opcode = 0x01,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "MUL",
        .opcode = 0x02,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "SUB",
        .opcode = 0x03,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "PUSH1",
        .opcode = 0x60,
        .size = 2,
        .payload_type = struct {
            value: Word,
        },
    },
};

fn defineOpcodes() type {
    var enumDecls: [instruction_definitions.len]std.builtin.Type.EnumField = undefined;

    inline for (instruction_definitions, 0..) |def, index| {
        enumDecls[index] = .{
            .name = def.mnemonic,
            .value = def.opcode,
        };
    }

    return @Type(.{
        .Enum = .{
            .tag_type = u8,
            .fields = &enumDecls,
            .decls = &.{},
            .is_exhaustive = true,
        }
    });
}

fn defineInstructions() type {
    var variants: [instruction_definitions.len]std.builtin.Type.UnionField = undefined;

    inline for (instruction_definitions, 0..) |def, index| {
        variants[index] = .{
            .name = def.mnemonic,
            .type = def.payload_type,
            .alignment = @alignOf(def.payload_type),
        };
    }

    return @Type(.{
        .Union = .{
            .tag_type = Opcode,
            .layout = .Auto,
            .fields = &variants,
            .decls = &.{},
        }
    });
}

pub fn getInstructionSize(opcode: Opcode) usize {
    return switch (opcode) {
        inline else => |_| {
            const instruction_size = blk: {
                inline for (instruction_definitions) |def| {
                    if (@intFromEnum(opcode) == def.opcode) {
                        break :blk def.size;
                    }
                }
                break :blk null;
            };

            return instruction_size.?;
        }
    };
}