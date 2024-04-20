const evm = @import("evm");
const Interpreter = evm.Interpreter;
const Opcode = evm.Opcode;

const JumpError = error {
    InvalidJumpLocation,
};

pub inline fn stop(interp: *Interpreter) !void {
    interp.status = .Halted;
}

pub inline fn jump(interp: *Interpreter) !void {
    const destination = interp.stack.pop();

    var frame = interp.frames.top().?;
    const code = frame.executing_contract.code;

    if (code[@truncate(destination)] != @intFromEnum(Opcode.JUMPDEST)) {
        return error.InvalidJumpLocation;
    }
    frame.program_counter = @as(usize, @truncate(destination));
}

pub inline fn jumpi(interp: *Interpreter) JumpError!void {
    const destination = interp.stack.pop();
    const condition = interp.stack.pop();

    var frame = interp.frames.top().?;
    const code = frame.executing_contract.code;

    if (code[@truncate(destination)] != @intFromEnum(Opcode.JUMPDEST)) {
        return error.InvalidJumpLocation;
    }
    if (condition != 0) {
        frame.program_counter = @as(usize, @truncate(destination));
    }
}

pub inline fn jumpdest(interp: *Interpreter) !void {
    _ = interp;
    // this is just a marker in the bytecode denoting a valid
    // jump location and has no effect on the machine state
}

pub inline fn pc(interp: *Interpreter) !void {
    // Program counter is advanced before executing the instruction
    const frame = interp.frames.top().?;
    try interp.stack.push(frame.program_counter - 1);
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
