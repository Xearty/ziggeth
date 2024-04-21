const Interpreter = @import("../../Interpreter.zig");

pub inline fn log2(interp: *Interpreter) !void {
    interp.status = .Halted;
}
