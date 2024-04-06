const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const evm = @import("root").Context;
const instructions = @import("evm_instructions");
const opcodes = instructions.opcodes;


pub fn decompile(allocator: Allocator, bytecode: []const u8) ![]u8 {
    var buffer: [1024]u8 = undefined;
    var decompiled_bytecode = ArrayList(u8).init(allocator);

    var counter: usize = 0;
    while (counter < bytecode.len) {
        const opcode = opcodes.fromByte(bytecode[counter]);
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
