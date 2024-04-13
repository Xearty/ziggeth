const Interpreter = @import("evm").Interpreter;

pub inline fn codesize(interp: *Interpreter) !void {
    try interp.stack.push(interp.bytecode.len);
}
