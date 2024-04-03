const constants = @import("constants.zig");
const utils = @import("utils.zig");
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
        inline else => |data, tag| {
            if (comptime instructions.isQuantifiedInstruction(@tagName(tag), "PUSH")) |_| {
                try ctx.stack.append(data.value);
            }
            if (comptime instructions.isQuantifiedInstruction(@tagName(tag), "DUP")) |quantity| {
                const offset = ctx.stack.items.len - quantity;
                const value = ctx.stack.items[offset];
                try ctx.stack.append(value);
            }
            if (comptime instructions.isQuantifiedInstruction(@tagName(tag), "SWAP")) |quantity| {
                const bot_offset = ctx.stack.items.len - quantity - 1;
                const top_offset = ctx.stack.items.len - 1;
                utils.swap(constants.WordType, &ctx.stack.items[bot_offset], &ctx.stack.items[top_offset]);
            }
        },
    }
}

pub fn executeBytecode(ctx: *Context, bytecode: []const u8) !void {
    while (!ctx.is_halted and ctx.program_counter < bytecode.len) {
        const instruction = try instructions.decode(bytecode[ctx.program_counter..]);
        ctx.program_counter += instructions.getInstructionSize(instruction);
        try executeInstruction(ctx, &instruction);
    }
}