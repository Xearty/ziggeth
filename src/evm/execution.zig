const Context = @import("context.zig").Context;
const instructions = @import("instructions.zig");
const Instruction = instructions.Instruction;

pub fn executeInstruction(ctx: *Context, instruction: *const Instruction) !void {
    switch (instruction.*) {
        .STOP => ctx.is_halted = true,
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
        .MOD => {
            const operand1 = ctx.stack.popOrNull().?;
            const operand2 = ctx.stack.popOrNull().?;
            try ctx.stack.append(operand1 % operand2);
        },
        .PUSH1, .PUSH2, .PUSH3, .PUSH4, .PUSH5, .PUSH6, .PUSH7,
        .PUSH8, .PUSH9, .PUSH10, .PUSH11, .PUSH12, .PUSH13,
        .PUSH14, .PUSH15, .PUSH16, .PUSH17, .PUSH18, .PUSH19,
        .PUSH20, .PUSH21, .PUSH22, .PUSH23, .PUSH24, .PUSH25,
        .PUSH26, .PUSH27, .PUSH28, .PUSH29, .PUSH30, .PUSH31,
        .PUSH32 => |data| try ctx.stack.append(data.value),
    }
}

pub fn executeBytecode(ctx: *Context, bytecode: []const u8) !void {
    while (!ctx.is_halted and ctx.program_counter < bytecode.len) {
        const instruction = instructions.decode(bytecode[ctx.program_counter..]);
        ctx.program_counter += instructions.getInstructionSize(instruction);
        try executeInstruction(ctx, &instruction);
    }
}