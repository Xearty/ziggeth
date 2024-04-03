const Context = @import("context.zig").Context;
const instructions = @import("instructions.zig");
const Instruction = instructions.Instruction;

pub fn executeInstruction(ctx: *Context, instruction: *const Instruction) !void {
    switch (instruction.*) {
        .STOP => {
            ctx.is_halted = true;
        },
        .ADD => {
            const operand1 = ctx.stack.popOrNull().?;
            const operand2 = ctx.stack.popOrNull().?;
            try ctx.stack.append(operand1 +% operand2);
        },
        .MUL => {
            const operand1 = ctx.stack.popOrNull().?;
            const operand2 = ctx.stack.popOrNull().?;
            try ctx.stack.append(operand1 *% operand2);
        },
        .SUB => {
            const operand1 = ctx.stack.popOrNull().?;
            const operand2 = ctx.stack.popOrNull().?;
            try ctx.stack.append(operand1 -% operand2);
        },
        .DIV => {
            const operand1 = ctx.stack.popOrNull().?;
            const operand2 = ctx.stack.popOrNull().?;
            try ctx.stack.append(operand1 / operand2);
        },
        .PUSH1 => |data| {
            try ctx.stack.append(data.value);
        },
    }
}

pub fn executeBytecode(ctx: *Context, bytecode: []const u8) !void {
    while (!ctx.is_halted and ctx.program_counter < bytecode.len) {
        const instruction = instructions.decode(bytecode[ctx.program_counter..]);
        ctx.program_counter += instructions.getInstructionSize(instruction);
        try executeInstruction(ctx, &instruction);
    }
}