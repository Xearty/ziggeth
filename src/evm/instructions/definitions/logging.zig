const Interpreter = @import("evm").Interpreter;

pub inline fn log2(interp: *Interpreter) !void {
    interp.status = .Halted;
}
