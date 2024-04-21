const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const utils = @import("evm_utils");

pub const List = struct {
    inner: ArrayList(Item),

    pub fn init(allocator: Allocator) List {
        return .{
            .inner = ArrayList(Item).init(allocator),
        };
    }

    pub fn deinit(self: *List) void {
        for (self.inner.items) |*item| {
            item.deinit();
        }
        self.inner.deinit();
    }

    pub fn encode(self: *const List, bytes: *ArrayList(u8)) RLPEncodingError!u64 {
        const list_offset: u64 = bytes.items.len;

        var content_bytes_cnt: u64 =  0;
        for (self.inner.items) |item| {
            content_bytes_cnt += try item.encode(bytes);
        }

        // NOTE: this is very inefficient, this will change once I switch to using
        // fixed-size buffers for rlp serialization. This is possible since it's an
        // error to have longer than 2**16 bytes long encoding, so it's sufficient to
        // assert this on every step
        var len_bytes_buffer = ArrayList(u8).init(self.inner.allocator);
        defer len_bytes_buffer.deinit();

        const len_bytes_cnt = try encodeLength(&len_bytes_buffer, content_bytes_cnt, 0xc0);
        try bytes.insertSlice(list_offset, len_bytes_buffer.items);

        return len_bytes_cnt + content_bytes_cnt;
    }

    pub fn print(self: *const List) void {
        if (self.inner.items.len == 0) {
            std.debug.print("[]", .{});
            return;
        }

        std.debug.print("[", .{});
        self.inner.items[0].print();

        for (1..self.inner.items.len) |index| {
            std.debug.print(", ", .{});
            self.inner.items[index].print();
        }
        std.debug.print("]", .{});
    }
};

pub const String = struct {
    data: []u8,
    allocator: Allocator,

    pub fn init(allocator: Allocator, data: []const u8) !String {
        return .{
            .data = try allocator.dupe(u8, data),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *String) void {
        self.allocator.free(self.data);
    }

    pub fn encode(self: *const String, bytes: *ArrayList(u8)) RLPEncodingError!u64 {
        if (self.data.len == 1 and self.data[0] < 0x80) {
            try bytes.append(self.data[0]);
            return 1;
        }

        const len_encoding_bytes_cnt = try encodeLength(bytes, self.data.len, 0x80);
        try bytes.appendSlice(self.data);
        return len_encoding_bytes_cnt + self.data.len;
    }

    pub fn print(self: *const String) void {
        std.debug.print("\"{s}\"", .{self.data});
    }
};

pub const Item = union(enum) {
    string: String,
    list: List,

    pub fn deinit(self: *Item) void {
        switch (self.*) {
            .string => |*string| string.deinit(),
            .list => |*list| list.deinit(),
        }
    }

    pub fn encode(self: *const Item, bytes: *ArrayList(u8)) RLPEncodingError!u64 {
        return switch (self.*) {
            .string => |string| try string.encode(bytes),
            .list => |list| try list.encode(bytes),
        };
    }

    pub fn print(self: *const Item) void {
        switch (self.*) {
            .string => |string| string.print(),
            .list => |list| list.print(),
        }
    }

    pub fn decode(allocator: Allocator, bytes: []const u8) RLPDecodingError!Item {
        if (bytes.len == 0) return error.InvalidEncoding;

        const decoded_len = try decodeLength(bytes);
        const item_type = decoded_len.item_type;
        const len_bytes_count = decoded_len.bytes_count;
        const data_length = decoded_len.data_length;

        if (bytes.len != len_bytes_count + data_length) return error.InvalidEncoding;

        switch (item_type) {
            .string => {
                const string_content = bytes[len_bytes_count..len_bytes_count+data_length];
                return Item { .string = try String.init(allocator, string_content) };
            },
            .list => {
                var list = List.init(allocator);
                var content_bytes = bytes[len_bytes_count..];
                while (content_bytes.len != 0) {
                    const decoded_item_len = try decodeLength(content_bytes);
                    const item_length = decoded_item_len.bytes_count + decoded_item_len.data_length;

                    if (content_bytes.len < item_length) {
                        return error.InvalidEncoding;
                    }

                    const item = try Item.decode(allocator, content_bytes[0..item_length]);
                    try list.inner.append(item);

                    content_bytes = content_bytes[item_length..];
                }
                return Item { .list = list };
            },
        }
    }
};

pub const ListBuilder = struct {
    list: List,

    pub fn init(allocator: Allocator) ListBuilder {
        return .{
            .list = List.init(allocator),
        };
    }

    pub fn deinit(self: *ListBuilder) void {
        self.list.deinit();
    }

    pub fn appendString(self: *ListBuilder, data: []const u8) !void {
        const item = try String.init(self.list.inner.allocator, data);
        try self.list.inner.append(.{ .string = item });
    }

    pub fn appendList(self: *ListBuilder, list: List) !void {
        try self.list.inner.append(.{ .list = list });
    }

    pub fn print(self: *const ListBuilder) void {
        self.list.print();
    }
};

const RLPEncodingError = error {
    InputTooLong,
    OutOfMemory,
};

const RLPDecodingError = error {
    InputIsNull,
    InvalidEncoding,
    OutOfMemory,
};

const ItemType = enum {
    string,
    list,
};

const DecodeLengthResult = struct {
    bytes_count: u64,
    data_length: u64,
    item_type: ItemType,
};

fn encodeLength(bytes: *ArrayList(u8), length: u64, offset: u64) !u64 {
    if (length < 56) {
        try bytes.append(@truncate(offset + length));
        return 1;
    }

    if (length < 65536) {
        const len_bytes = [_]u8{
            @truncate(length >> 8 & 0xff),
            @truncate(length & 0xff)
        };
        const len_len: u8 = if (len_bytes[0] == 0x00) 1 else 2;

        try bytes.append(@truncate(offset + 55 + len_len));

        if (len_len == 2) {
            try bytes.append(len_bytes[0]);
        }
        try bytes.append(len_bytes[1]);
        return 1 + len_len;
    }

    return error.InputTooLong;
}

fn decodeLength(bytes: []const u8) RLPDecodingError!DecodeLengthResult {
    const length = bytes.len;
    if (length == 0) return error.InputIsNull;

    const prefix = bytes[0];
    if (prefix <= 0x7f) {
        return .{
            .bytes_count = 0,
            .data_length = 1,
            .item_type = .string,
        };
    }

    if (prefix <= 0xb7 and length > prefix - 0x80) {
        return .{
            .bytes_count = 1,
            .data_length = prefix - 0x80,
            .item_type = .string,
        };
    }

    if (prefix <= 0xbf) {
        const len_of_str_len = prefix - 0xb7;
        const str_len = utils.intFromBigEndianBytes(u16, bytes[1..1+len_of_str_len]);
        if (length > prefix -% 0xb7 +% str_len) {
            return .{
                .bytes_count = 1 + len_of_str_len,
                .data_length = str_len,
                .item_type = .string,
            };
        }
    }

    if (prefix <= 0xf7 and length > prefix - 0xc0) {
        return .{

            .bytes_count = 1,
            .data_length = prefix - 0xc0,
            .item_type = .list,
        };
    }

    if (prefix <= 0xff) {
        const len_of_list_len = prefix - 0xf7;
        const list_len = utils.intFromBigEndianBytes(u16, bytes[1..1+len_of_list_len]);
        if (length > prefix -% 0xf7 +% list_len) {
            return .{
                .bytes_count = 1 + len_of_list_len,
                .data_length = list_len,
                .item_type = .list,
            };
        }
    }

    return error.InvalidEncoding;
}
