const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const evm = @import("root").Interpreter;
const instructions = @import("./instructions/instructions.zig");
const opcodes = instructions.opcodes;
const utils = @import("evm_utils");

pub fn decompile(allocator: Allocator, bytecode: []const u8) ![]u8 {
    var buffer: [1024]u8 = undefined;
    var decompiled_bytecode = ArrayList(u8).init(allocator);

    const number_column_len = utils.getNumberLength(usize, bytecode.len);

    var counter: usize = 0;
    while (counter < bytecode.len) {
        const opcode_offset = try std.fmt.bufPrint(&buffer, "{}:", .{counter});
        try decompiled_bytecode.appendSlice(opcode_offset);

        const counter_len = utils.getNumberLength(usize, counter);
        for (counter_len..number_column_len+1) |_| try decompiled_bytecode.append(' ');

        std.debug.print("counter: {}\n", .{counter});
        const opcode = opcodes.fromByte(bytecode[counter]);
        std.debug.print("offset: {} | byte: 0x{x} | opcode: {}\n", .{counter, bytecode[counter], opcode});
        try decompiled_bytecode.appendSlice(@tagName(opcode));

        const args_offset = counter + 1;
        counter += instructions.getSize(opcode);
        const args = bytecode[args_offset..counter];
        for (args) |byte| {
            const hex_byte = try std.fmt.bufPrint(&buffer, " 0x{x}", .{byte});
            try decompiled_bytecode.appendSlice(hex_byte);
        }
        try decompiled_bytecode.append('\n');
    }
    _ = decompiled_bytecode.pop();
    return decompiled_bytecode.toOwnedSlice();
}
