const Interpreter = @import("evm").Interpreter;

pub inline fn codesize(interp: *Interpreter) !void {
    try interp.stack.push(interp.bytecode.len);
}

// TODO: do this without branching
pub inline fn codecopy(interp: *Interpreter) !void {
    const dest_offset = interp.stack.pop();
    const offset = interp.stack.pop();
    const size: usize = @intCast(interp.stack.pop());

    for (0..size) |index| {
        const memoryIndex: usize = @truncate(dest_offset + index);
        const bytecodeIndex: usize = @truncate(offset + index);
        if (bytecodeIndex < interp.bytecode.len) {
            try interp.memory.store8(interp.bytecode[bytecodeIndex], memoryIndex);
        } else {
            try interp.memory.store8(0x00, memoryIndex);
        }
    }
}
