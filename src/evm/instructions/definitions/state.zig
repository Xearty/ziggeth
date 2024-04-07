const evm = @import("evm");
const Interpreter = evm.Interpreter;

pub inline fn stop(interp: *Interpreter) !void {
    interp.status = .HALTED;
}

pub inline fn jump(interp: *Interpreter) !void {
    interp.program_counter = @as(usize, @truncate(interp.stack.pop()));
}

pub inline fn jumpi(interp: *Interpreter) !void {
    const destination = interp.stack.pop();
    const condition = interp.stack.pop();
    if (condition != 0) {
        interp.program_counter = @as(usize, @truncate(destination));
    }
}

pub inline fn pc(interp: *Interpreter) !void {
    // Program counter is advanced before executing the instruction
    try interp.stack.push(interp.program_counter - 1);
}

pub fn mload(interp: *Interpreter) !void {
    const offset = interp.stack.pop();
    const value = interp.memory.load(@intCast(offset));
    try interp.stack.push(value);
}

pub fn mstore(interp: *Interpreter) !void {
    const offset = interp.stack.pop();
    const value = interp.stack.pop();
    try interp.memory.store(value, @intCast(offset));
}

pub fn mstore8(interp: *Interpreter) !void {
    const offset = interp.stack.pop();
    const value = interp.stack.pop();
    try interp.memory.store8(@truncate(value), @intCast(offset));
}

pub fn msize(interp: *Interpreter) !void {
    try interp.stack.push(interp.memory.size());
}
