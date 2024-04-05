const std = @import("std");
const evm = @import("evm");

pub fn main() !void {
    const bytecode: []const u8 = &.{
        @intFromEnum(evm.Opcode.PUSH1), 0x2,
        @intFromEnum(evm.Opcode.PUSH1), 0x1,
        @intFromEnum(evm.Opcode.SWAP1),
        @intFromEnum(evm.Opcode.PUSH1), 0x5,
        @intFromEnum(evm.Opcode.MUL),
    };

    var evm_context = evm.Context.init(std.heap.page_allocator, bytecode);
    defer evm_context.deinit();

    try evm.execute(&evm_context);
    std.debug.print("{}\n", .{evm_context.stack});
}
