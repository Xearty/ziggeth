const std = @import("std");
const instruction_definitions = @import("instruction_definitions.zig").instruction_definitions;

pub const Opcode = DefineOpcodes();
pub const Instruction = DefineInstructions();

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
