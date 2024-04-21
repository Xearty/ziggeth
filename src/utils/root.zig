const std = @import("std");
const Allocator = std.mem.Allocator;
const Keccak256 = std.crypto.hash.sha3.Keccak256;
const print = std.debug.print;
const Word = @import("eth_types").Word;

pub const BinaryBufferBuilder = @import("BinaryBufferBuilder.zig");

pub fn computeFunctionSelector(signature: []const u8) u32 {
    var hash: [32]u8 = undefined;
    Keccak256.hash(signature, &hash, .{});
    return intFromBigEndianBytes(u32, hash[0..4]);
}

pub fn intFromBigEndianBytes(comptime T: type, bytes: []const u8) T {
    std.debug.assert(bytes.len <= @sizeOf(T));
    var result: T = 0;
    for (bytes) |byte| result = (result << 8) | byte;
    return result;
}

pub fn bigEndianBytesFromInt(comptime T: type, integer: T) [@sizeOf(T)]u8 {
    var buffer: [@sizeOf(T)]u8 = undefined;
    for (0..@sizeOf(T)) |i| {
        buffer[i] = @truncate(extractIthByte(T, integer, @intCast(i)));
    }
    return buffer;
}

pub fn hexCharacterToDecimal(hex_char: u8) u8 {
    if (hex_char >= '0' and hex_char <= '9') return hex_char - '0';
    if (hex_char >= 'a' and hex_char <= 'f') return hex_char - 'a' + 10;
    unreachable;
}

pub fn hexToBytesOwned(allocator: Allocator, hex_string: []const u8) ![]u8 {
    const bytes_count = hex_string.len / 2;
    var buffer = try allocator.alloc(u8, bytes_count);

    var offset: usize = 0;
    while (offset < bytes_count) : (offset += 1) {
        const first_char = hexCharacterToDecimal(hex_string[offset * 2]);
        const second_char = hexCharacterToDecimal(hex_string[offset * 2 + 1]);
        buffer[offset] = first_char * 16 + second_char;
    }

    return buffer;
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
            print("1", .{});
        } else {
            print("0", .{});
        }
    }
    print("\n", .{});
}

// TODO: maybe do this return a u8
pub fn extractIthByte(comptime T: type, value: T, i: T) T {
    const ShiftType = std.math.Log2Int(T);
    return (value >> @as(ShiftType, @truncate((248 - i * 8)))) & 0xff;
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

pub fn getNumberLength(comptime T: type, number: T) u32 {
    if (number == 0) return 1;
    var num: T = number;
    var length: u32 = 0;

    while (num != 0) {
        length += 1;
        num /= 10;
    }
    return length;
}

pub fn toLower(string: []const u8) []const u8 {
    var buf: [string.len]u8 = undefined;
    return std.ascii.lowerString(&buf, string);
}

