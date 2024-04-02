const instructions = @import("instructions.zig");

pub const Opcode = @import("opcodes.zig").Opcode;
pub const Instruction = instructions.Instruction;
pub const Context = @import("context.zig").Context;

pub fn executeInstruction(ctx: *Context, instruction: *const Instruction) !void {
    switch (instruction.*) {
        .PUSH1 => |data| {
            try ctx.stack.append(data.value);
        },
        .ADD => {
            const operand1 = ctx.stack.popOrNull().?;
            const operand2 = ctx.stack.popOrNull().?;
            try ctx.stack.append(operand1 + operand2);
        }
    }
}

pub fn executeBytecode(ctx: *Context, bytecode: []const u8) !void {
    while (ctx.program_counter < bytecode.len) {
        const instruction = instructions.decode(bytecode[ctx.program_counter..]);
        try executeInstruction(ctx, &instruction);
        ctx.program_counter += instructions.getSize(instruction);
    }
}