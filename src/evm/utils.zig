const WordType = @import("constants.zig").WordType;

pub fn wordFromBigEndianBytes(bytes: []const u8) WordType {
    var result: WordType = 0;
    for (bytes) |byte| result = (result << 8) | byte;
    return result;
}

pub fn swap(comptime T: type, a: *T, b: *T) void {
    const temp = a.*;
    a.* = b.*;
    b.* = temp;
}