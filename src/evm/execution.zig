const std = @import("std");
const utils = @import("evm_utils");
const instructions = @import("evm_instructions");
const opcodes = instructions.opcodes;
const constants = @import("constants");
const math = @import("math");
const Interpreter = @import("Interpreter.zig");
const Word = constants.Word;
const SignedWord = constants.SignedWord;

pub fn execute(interp: *Interpreter) !void {
    while (interp.status == .RUNNING) {
        const opcode = opcodes.fromByte(interp.bytecode[interp.program_counter]);
        interp.advanceProgramCounter(instructions.getSize(opcode));
        try executeInstruction(interp, opcode);
    }
}

fn executeInstruction(interp: *Interpreter, opcode: opcodes.Opcode) !void {
    @setEvalBranchQuota(10000);
    switch (opcode) {
        inline else => |tag| {
            if (comptime instructions.isQuantified(tag)) |unquantified_tag| {
                const quantity = comptime instructions.extractQuantity(tag);
                try @field(instructions, utils.toLower(unquantified_tag))(interp, quantity);
            } else {
                const function = comptime utils.toLower(@tagName(tag));
                try @field(instructions, function)(interp);
            }
        }
    }
}
