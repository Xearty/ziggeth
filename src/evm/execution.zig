const utils = @import("utils.zig");
const instructions = @import("instructions.zig");
const constants = @import("constants");
const math = @import("math");
const Context = @import("context.zig").Context;
const Instruction = instructions.Instruction;
const Word = constants.Word;
const SignedWord = constants.SignedWord;

pub fn executeInstruction(ctx: *Context, instruction: *const Instruction) !void {
    switch (instruction.*) {
        .STOP => ctx.is_halted = true,
        .ADD => {
            const operand1 = ctx.stack.pop();
            const operand2 = ctx.stack.pop();
            try ctx.stack.push(operand1 +% operand2);
        },
        .MUL => {
            const operand1 = ctx.stack.pop();
            const operand2 = ctx.stack.pop();
            try ctx.stack.push(operand1 *% operand2);
        },
        .SUB => {
            const operand1 = ctx.stack.pop();
            const operand2 = ctx.stack.pop();
            try ctx.stack.push(operand1 -% operand2);
        },
        .DIV => {
            const operand1 = ctx.stack.pop();
            const operand2 = ctx.stack.pop();
            try ctx.stack.push(operand1 / operand2);
        },
        .SDIV => {
            const operand1 = @as(SignedWord, @bitCast(ctx.stack.pop()));
            const operand2 = @as(SignedWord, @bitCast(ctx.stack.pop()));
            const result = @divTrunc(operand1, operand2);
            try ctx.stack.push(@as(Word, @bitCast(result)));
        },
        .MOD => {
            const operand1 = ctx.stack.pop();
            const operand2 = ctx.stack.pop();
            try ctx.stack.push(operand1 % operand2);
        },
        .SMOD => {
            const operand1 = @as(SignedWord, @bitCast(ctx.stack.pop()));
            const operand2 = @as(SignedWord, @bitCast(ctx.stack.pop()));
            const result = @mod(operand1, operand2);
            try ctx.stack.push(@as(Word, @bitCast(result)));
        },
        .ADDMOD => {
            const operand1 = ctx.stack.pop();
            const operand2 = ctx.stack.pop();
            const operand3 = ctx.stack.pop();
            const result = (operand1 + operand2) % operand3;
            try ctx.stack.push(result);
        },
        .MULMOD => {
            const operand1 = ctx.stack.pop();
            const operand2 = ctx.stack.pop();
            const operand3 = ctx.stack.pop();
            const result = (operand1 * operand2) % operand3;
            try ctx.stack.push(result);
        },
        .EXP => {
            const operand1 = ctx.stack.pop();
            const operand2 = ctx.stack.pop();
            try ctx.stack.push(math.pow(Word, operand1, operand2));
        },
        .SIGNEXTEND => {
            const operand1 = ctx.stack.pop();
            const operand2 = ctx.stack.pop();
            try ctx.stack.push(utils.signExtend(operand2, operand1));
        },
        inline else => |data, tag| {
            if (comptime instructions.isQuantified(tag, "PUSH")) |_| try ctx.stack.push(data.value);
            if (comptime instructions.isQuantified(tag, "DUP")) |offset| try ctx.stack.dup(offset);
            if (comptime instructions.isQuantified(tag, "SWAP")) |offset| try ctx.stack.swap(offset);
        },
    }
}

pub fn executeBytecode(ctx: *Context, bytecode: []const u8) !void {
    while (!ctx.is_halted and ctx.program_counter < bytecode.len) {
        const instruction = try instructions.decode(bytecode[ctx.program_counter..]);
        ctx.program_counter += instructions.getSize(instruction);
        try executeInstruction(ctx, &instruction);
    }
}
