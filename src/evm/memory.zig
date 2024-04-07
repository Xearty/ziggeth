const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Word = @import("constants").Word;
const utils = @import("evm_utils");

pub const Memory = struct {
    const Self = @This();
    const InnerType = ArrayList(u8);
    const reserved_slots_count = 4;

    inner: InnerType,
    highest_used_address: usize,

    pub fn init(allocator: Allocator) !Self {
        var inner = try InnerType.initCapacity(allocator, reserved_slots_count * @sizeOf(Word));
        inner.appendNTimesAssumeCapacity(0, inner.capacity);
        return Self {
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

        const bytes = utils.bigEndianBytesFromWord(value);
        for (0..@sizeOf(Word)) |i| self.inner.items[offset + i] = bytes[i];

        self.highest_used_address = @max(self.highest_used_address, offset);
    }

    pub fn load(self: *Self, offset: usize) Word {
        std.debug.assert(offset <= self.highest_used_address);
        return utils.wordFromBigEndianBytes(self.inner.items[offset..offset+@sizeOf(Word)]);
    }

    pub fn prettyPrint(self: *const Self) !void {
        var buffer: [1024]u8 = undefined;
        var message = std.ArrayList(u8).init(self.inner.allocator);
        const number_column_len = utils.getNumberLength(usize, self.highest_used_address);

        for (self.inner.items[0..self.highest_used_address+1], 0..) |word, index| {
            const address_number = try std.fmt.bufPrint(&buffer, "{}:", .{index});
            try message.appendSlice(address_number);

            const address_len = utils.getNumberLength(usize, index);
            for (address_len..number_column_len+1) |_| try message.append(' ');

            const line = try std.fmt.bufPrint(&buffer, "{}", .{word});
            try message.appendSlice(line);
            try message.append('\n');
        }

        _ = message.popOrNull();
        utils.printBoxed("Memory", message.items);
    }
};
