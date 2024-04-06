const std = @import("std");
const print = std.debug.print;
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

pub fn extractIthByte(comptime T: type, value: T, i: T) T {
    return (value >> (248 - @as(u8, @truncate(i)) * 8)) & 0xff;
}

fn determineLongestLine(str: []const u8) usize {
    var longest_line_len: usize = 0;

    var lines = std.mem.split(u8, str, "\n");
    while (lines.next()) |line| {
        longest_line_len = @max(longest_line_len, line.len);
    }

    return longest_line_len;
}

// TODO: maybe add a padding parameter
pub fn printBoxed(title: []const u8, message: []const u8) void {
    const longest_line = @max(determineLongestLine(message), title.len);
    const box_width = longest_line + 2;

    print("╭", .{});
    for (0..box_width - 2) |_| {
        print("─", .{});
    }
    print("╮\n", .{});

    print("│{s}", .{title});
    for (title.len..longest_line) |_| print(" ", .{});
    print("│\n", .{});

    print("├", .{});
    for (0..box_width-2) |_| print("─", .{});
    print("┤\n", .{});

    var lines = std.mem.split(u8, message, "\n");
    while (lines.next()) |line| {
        print("│", .{});
        print("{s}", .{line});
        for (line.len..longest_line) |_| print(" ", .{});
        print("│\n", .{});

    }

    print("╰", .{});
    for (0..box_width - 2) |_| {
        print("─", .{});
    }
    print("╯\n", .{});

}

