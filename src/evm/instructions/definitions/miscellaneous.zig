const Interpreter = @import("evm").Interpreter;

pub inline fn invalid(interp: *Interpreter) !void {
    interp.status = .HALTED;
}
