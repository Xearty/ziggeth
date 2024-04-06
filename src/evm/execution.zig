const std = @import("std");
const utils = @import("evm_utils");
const instructions = @import("evm_instructions");
const opcodes = instructions.opcodes;
const constants = @import("constants");
const math = @import("math");
const Context = @import("context.zig").Context;
const Word = constants.Word;
const SignedWord = constants.SignedWord;

pub fn execute(ctx: *Context) !void {
    while (ctx.status == .RUNNING) {
        const opcode = opcodes.fromByte(ctx.bytecode[ctx.program_counter]);
        ctx.advanceProgramCounter(instructions.getSize(opcode));
        try executeInstruction(ctx, opcode);
    }
}

fn executeInstruction(ctx: *Context, opcode: opcodes.Opcode) !void {
    @setEvalBranchQuota(10000);
    switch (opcode) {
        inline else => |tag| {
            if (comptime instructions.isQuantified(tag)) |unquantified_tag| {
                const quantity = comptime instructions.extractQuantity(tag);
                try @field(instructions, utils.toLower(unquantified_tag))(ctx, quantity);
            } else {
                const function = comptime utils.toLower(@tagName(tag));
                try @field(instructions, function)(ctx);
            }
        }
    }
}
