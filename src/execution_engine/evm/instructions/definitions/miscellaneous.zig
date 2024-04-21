const Interpreter = @import("../../Interpreter.zig");

pub inline fn invalid(interp: *Interpreter) !void {
    // TODO: set frame status to .Reverted
    interp.status = .Halted;
    interp.clearReturnData();
}

pub inline fn revert(interp: *Interpreter) !void {
    interp.status = .Halted;
}

pub inline fn @"return"(interp: *Interpreter) !void {
    const offset = interp.stack.pop();
    const size = interp.stack.pop();

    var frame = interp.frames.top().?;
    frame.status = .Returned;

    const returned_bytes = interp.memory.get(@intCast(offset), @intCast(size));
    try interp.setReturnData(returned_bytes);
}

