const Interpreter = @import("evm").Interpreter;

pub inline fn invalid(interp: *Interpreter) !void {
    // TODO: set frame status to .Reverted
    interp.status = .HALTED;
    interp.clearReturnData();
}

pub inline fn revert(interp: *Interpreter) !void {
    interp.status = .HALTED;
}

pub inline fn @"return"(interp: *Interpreter) !void {
    const offset = interp.stack.pop();
    const size = interp.stack.pop();

    var frame = interp.frames.top().?;
    frame.status = .Returned;

    const returned_bytes = interp.memory.get(@intCast(offset), @intCast(size));
    try interp.setReturnData(returned_bytes);
}

