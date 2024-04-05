const std = @import("std");
const EnumField = std.builtin.Type.EnumField;
const UnionField = std.builtin.Type.UnionField;

const defs = @import("instruction_definitions.zig").instruction_definitions;

pub const Opcode = DefineOpcodes();
pub const Instruction = DefineInstructions();

fn DefineOpcodes() type {
    var enumDecls: [defs.len]EnumField = undefined;

    inline for (defs, 0..) |def, index| {
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
    var variants: [defs.len]UnionField = undefined;

    inline for (defs, 0..) |def, index| {
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
