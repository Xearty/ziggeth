const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Word = @import("eth_types").Word;
const utils = @import("utils");

const Self = @This();
const InnerType = ArrayList(u8);
const reserved_slots_count = 4;

inner: InnerType,
highest_used_address: usize,

pub fn init(allocator: Allocator) !Self {
    var inner = try InnerType.initCapacity(allocator, reserved_slots_count * @sizeOf(Word));
    inner.appendNTimesAssumeCapacity(0, inner.capacity);
    return .{
        .inner = inner,
        .highest_used_address = reserved_slots_count * @sizeOf(Word) - 1,
    };
}

pub fn deinit(self: *Self) void {
    self.inner.deinit();
}

pub fn store(self: *Self, value: Word, offset: usize) !void {
    try self.inner.ensureTotalCapacity(offset * @sizeOf(Word) + 1);
    const new_slots_count = self.inner.capacity - self.inner.items.len;
    self.inner.appendNTimesAssumeCapacity(0, new_slots_count);

    const bytes = utils.bigEndianBytesFromInt(Word, value);
    for (0..@sizeOf(Word)) |i| self.inner.items[offset + i] = bytes[i];

    self.highest_used_address = @max(self.highest_used_address, offset);
}

pub fn store8(self: *Self, byte: u8, offset: usize) !void {
    try self.inner.ensureTotalCapacity(offset + 1);
    const new_slots_count = self.inner.capacity - self.inner.items.len;
    self.inner.appendNTimesAssumeCapacity(0, new_slots_count);
    self.inner.items[offset] = byte;
    self.highest_used_address = @max(self.highest_used_address, offset);
}

pub fn load(self: *Self, offset: usize) Word {
    std.debug.assert(offset <= self.highest_used_address);
    return utils.intFromBigEndianBytes(Word, self.inner.items[offset..offset+@sizeOf(Word)]);
}

pub fn size(self: *Self) usize {
    return self.highest_used_address + 1;
}

pub fn get(self: *Self, offset: usize, length: usize) []const u8 {
    // TODO: Do bounds checking and return an error
    return self.inner.items[offset..offset+length];
}

pub fn prettyPrint(self: *const Self) !void {
    var buffer: [1024]u8 = undefined;
    var dump = std.ArrayList(u8).init(self.inner.allocator);
    defer dump.deinit();

    const bytes_per_line = 32;
    const last_displayed_address = self.highest_used_address / bytes_per_line * bytes_per_line;
    const number_column_len = utils.getNumberLength(usize, last_displayed_address);

    var rest = self.inner.items[0..self.highest_used_address+1];
    var line_idx: usize = 0;

    while (rest.len != 0) : (line_idx += 1) {
        const address_len = utils.getNumberLength(usize, line_idx * bytes_per_line);
        for (address_len..number_column_len) |_| try dump.append(' ');

        const address_number = try std.fmt.bufPrint(&buffer, "{}: ", .{line_idx * bytes_per_line});
        try dump.appendSlice(address_number);

        for (rest[0..@min(bytes_per_line, rest.len)]) |byte| {
            const formatted_byte = try std.fmt.bufPrint(&buffer, "{x:0>2} ", .{byte});
            try dump.appendSlice(formatted_byte);
        }
        try dump.append('\n');

        rest = rest[@min(bytes_per_line, rest.len)..];
    }

    _ = dump.popOrNull();
    utils.printBoxed("Memory", dump.items);
}
