const evm = @import("evm");
const Context = evm.Context;

pub inline fn stop(ctx: *Context) !void {
    ctx.status = .HALTED;
}

pub inline fn jump(ctx: *Context) !void {
    ctx.program_counter = @as(usize, @truncate(ctx.stack.pop()));
}

pub inline fn jumpi(ctx: *Context) !void {
    const destination = ctx.stack.pop();
    const condition = ctx.stack.pop();
    if (condition != 0) {
        ctx.program_counter = @as(usize, @truncate(destination));
    }
}

pub inline fn pc(ctx: *Context) !void {
    // Program counter is advanced before executing the instruction
    try ctx.stack.push(ctx.program_counter - 1);
}
