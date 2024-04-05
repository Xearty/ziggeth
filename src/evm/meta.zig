const std = @import("std");
const Word = @import("constants.zig").Word;

pub const Opcode = DefineOpcodes();
pub const Instruction = DefineInstructions();

const InstructionDefinition = struct {
    mnemonic: []const u8,
    opcode: u8,
    size: usize,
    payload_type: type,
};

const instruction_definitions =
    genPushInstructionDefinitions() ++
    genDupInstructionDefinitions() ++
    genSwapInstructionDefinitions() ++
    [_]InstructionDefinition{
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
        .mnemonic = "DIV",
        .opcode = 0x04,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "SDIV",
        .opcode = 0x05,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "MOD",
        .opcode = 0x06,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "SMOD",
        .opcode = 0x07,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "ADDMOD",
        .opcode = 0x08,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "MULMOD",
        .opcode = 0x09,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "EXP",
        .opcode = 0x0a,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "SIGNEXTEND",
        .opcode = 0x0b,
        .size = 1,
        .payload_type = void,
    },
};

fn DefineOpcodes() type {
    var enumDecls: [instruction_definitions.len]std.builtin.Type.EnumField = undefined;

    inline for (instruction_definitions, 0..) |def, index| {
        enumDecls[index] = .{
            .name = def.mnemonic ++ "",
            .value = def.opcode,
        };
    }

    return @Type(.{ .Enum = .{
        .tag_type = u8,
        .fields = &enumDecls,
        .decls = &.{},
        .is_exhaustive = true,
    } });
}

fn genPushInstructionDefinitions() [32]InstructionDefinition {
    const PushInstructionType = struct { value: Word };
    var definitions: [32]InstructionDefinition = undefined;

    inline for (0..32) |index| {
        definitions[index] = InstructionDefinition{
            .mnemonic = std.fmt.comptimePrint("PUSH{}", .{index + 1}),
            .opcode = 0x60 + index,
            .size = index + 2,
            .payload_type = PushInstructionType,
        };
    }
    return definitions;
}

fn genDupInstructionDefinitions() [16]InstructionDefinition {
    var definitions: [16]InstructionDefinition = undefined;

    inline for (0..16) |index| {
        definitions[index] = InstructionDefinition{
            .mnemonic = std.fmt.comptimePrint("DUP{}", .{index + 1}),
            .opcode = 0x80 + index,
            .size = 1,
            .payload_type = void,
        };
    }
    return definitions;
}

fn genSwapInstructionDefinitions() [16]InstructionDefinition {
    var definitions: [16]InstructionDefinition = undefined;

    inline for (0..16) |index| {
        definitions[index] = InstructionDefinition{
            .mnemonic = std.fmt.comptimePrint("SWAP{}", .{index + 1}),
            .opcode = 0x90 + index,
            .size = 1,
            .payload_type = void,
        };
    }
    return definitions;
}

fn DefineInstructions() type {
    var variants: [instruction_definitions.len]std.builtin.Type.UnionField = undefined;

    inline for (instruction_definitions, 0..) |def, index| {
        variants[index] = .{
            .name = def.mnemonic ++ "",
            .type = def.payload_type,
            .alignment = @alignOf(def.payload_type),
        };
    }

    return @Type(.{ .Union = .{
        .tag_type = Opcode,
        .layout = .Auto,
        .fields = &variants,
        .decls = &.{},
    } });
}

pub fn getInstructionSize(opcode: Opcode) usize {
    return switch (opcode) {
        inline else => |tag| {
            inline for (instruction_definitions) |def| {
                @setEvalBranchQuota(10000);
                if (comptime @intFromEnum(tag) == def.opcode) {
                    return def.size;
                }
            }
        },
    };
}
