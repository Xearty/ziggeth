const std = @import("std");
const Word = @import("constants").Word;

pub fn wordFromBigEndianBytes(bytes: []const u8) Word {
    var result: Word = 0;
    for (bytes) |byte| result = (result << 8) | byte;
    return result;
}

pub fn swap(comptime T: type, a: *T, b: *T) void {
    const temp = a.*;
    a.* = b.*;
    b.* = temp;
}

pub fn signExtend(value: Word, b: Word) Word {
    var result: Word = value;
    for (@as(usize, @intCast(b+1))..32) |byte_idx| {
        const shift = byte_idx * 8;
        result = result | @shlExact(@as(Word, 0xff), @intCast(shift));
    }
    return result;
}

pub fn printBits(value: Word) void {
    for (0..256) |index| {
        const bitmask = @as(Word, 1) << @intCast(255 - index);
        if (value & bitmask != 0) {
            std.debug.print("1", .{});
        } else {
            std.debug.print("0", .{});
        }
    }
    std.debug.print("\n", .{});
}
