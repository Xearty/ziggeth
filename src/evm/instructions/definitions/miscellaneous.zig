const Interpreter = @import("evm").Interpreter;

pub inline fn invalid(interp: *Interpreter) !void {
    interp.status = .HALTED;
}

pub inline fn revert(interp: *Interpreter) !void {
    interp.status = .HALTED;
}

pub inline fn @"return"(interp: *Interpreter) !void {
    interp.status = .HALTED;
}

