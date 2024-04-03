const std = @import("std");
const assert = std.debug.assert;

pub const Opcode = @import("meta.zig").Opcode;

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