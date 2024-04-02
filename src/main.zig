const std = @import("std");
const assert = std.debug.assert;
const print = std.debug.print;

const evm = @import("evm");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var evm_context = evm.Context.init(allocator);
    defer evm_context.deinit();

    const bytecode: []const u8 = &.{ 0x60, 0x69 };
    try evm.executeBytecode(&evm_context, bytecode);

    print("{}\n", .{evm_context});
}
