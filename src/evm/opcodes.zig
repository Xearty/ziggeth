const std = @import("std");
const assert = std.debug.assert;

pub const Opcode = enum(u8) {
    STOP = 0x00,
    ADD = 0x01,
    MUL = 0x02,
    PUSH1 = 0x60,
};

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