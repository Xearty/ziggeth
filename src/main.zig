const std = @import("std");
const evm = @import("evm");

pub fn main() !void {
    const bytecode: []const u8 = &.{
        @intFromEnum(evm.Opcode.PUSH1), 69,  // value
        @intFromEnum(evm.Opcode.PUSH1), 0x5, // key
        @intFromEnum(evm.Opcode.SSTORE),
        @intFromEnum(evm.Opcode.PUSH1), 0x5, // key
        @intFromEnum(evm.Opcode.SLOAD),
    };

    var evm_context = evm.Context.init(std.heap.page_allocator, bytecode);
    defer evm_context.deinit();

    try evm.execute(&evm_context);
    std.debug.print("{}\n", .{evm_context.stack});
}


// TODO: pretty printing for stack, storage and memory
