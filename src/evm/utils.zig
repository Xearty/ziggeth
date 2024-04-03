const Word = @import("constants.zig").Word;

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