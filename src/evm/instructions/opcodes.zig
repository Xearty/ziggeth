const std = @import("std");
const assert = std.debug.assert;

pub const Opcode = DefineOpcodes();

pub fn fromByte(byte: u8) Opcode {
    assert(isValidOpcode(byte));
    return @enumFromInt(byte);
}

fn isValidOpcode(byte: u8) bool {
    inline for (@typeInfo(Opcode).Enum.fields) |opcode| {
        if (byte == opcode.value) {
            return true;
        }
    }
    return false;
}

fn DefineOpcodes() type {
    const defs = @import("meta/metadata.zig").instructions_metadata;

    var enumDecls: [defs.len]std.builtin.Type.EnumField = undefined;
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

