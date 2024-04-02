const opcodes = @import("opcodes.zig");

pub const Instruction = union(opcodes.Opcode) {
    PUSH1: struct {
        value: u8,
    },
};

pub fn getSize(opcode: opcodes.Opcode) usize {
    return switch (opcode) {
        .PUSH1 => 2,
    };
}

pub fn decode(bytecode_stream: []const u8) Instruction {
    const opcode = opcodes.fromByte(bytecode_stream[0]);
    switch (opcode) {
        .PUSH1 => {
            const value = bytecode_stream[1];
            return Instruction{
                .PUSH1 = .{ .value = value },
            };
        },
    }
}