const opcodes = @import("opcodes.zig");
const Word = @import("constants.zig").Word;

pub const Instruction = union(opcodes.Opcode) {
    STOP: void,
    ADD: void,
    MUL: void,
    PUSH1: struct {
        value: Word,
    },
};

pub fn getSize(opcode: opcodes.Opcode) usize {
    return switch (opcode) {
        .STOP => 1,
        .ADD => 1,
        .MUL => 1,
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
        .ADD => return Instruction.ADD,
        .MUL => return Instruction.MUL,
        .STOP =>  return Instruction.STOP,
    }
}