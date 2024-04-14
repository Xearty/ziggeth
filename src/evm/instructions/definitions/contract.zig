const std = @import("std");
const Keccak256 = std.crypto.hash.sha3.Keccak256;
const Interpreter = @import("evm").Interpreter;
const utils = @import("evm_utils");
const Word = @import("types").Word;

pub inline fn codesize(interp: *Interpreter) !void {
    try interp.stack.push(interp.bytecode.len);
}

pub inline fn extcodesize(interp: *Interpreter) !void {
    const address = interp.stack.pop();
    const contract_code = interp.host.getContractCode(@truncate(address)).?;
    try interp.stack.push(contract_code.len);
}

// TODO: do this without branching
pub inline fn codecopy(interp: *Interpreter) !void {
    try codecopyImpl(interp, interp.bytecode);
}

pub inline fn extcodecopy(interp: *Interpreter) !void {
    const address = interp.stack.pop();
    const bytecode = interp.host.getContractCode(@truncate(address)).?;
    try codecopyImpl(interp, bytecode);
}

pub inline fn extcodehash(interp: *Interpreter) !void {
    const address = interp.stack.pop();
    const contract_code = interp.host.getContractCode(@truncate(address)).?;

    var hash: [32]u8 = undefined;
    Keccak256.hash(contract_code, &hash, .{});
    try interp.stack.push(utils.intFromBigEndianBytes(Word, &hash));
}

fn codecopyImpl(interp: *Interpreter, bytecode: []const u8) !void {
    const dest_offset = interp.stack.pop();
    const offset = interp.stack.pop();
    const size: usize = @intCast(interp.stack.pop());

    for (0..size) |index| {
        const memoryIndex: usize = @truncate(dest_offset + index);
        const bytecodeIndex: usize = @truncate(offset + index);
        if (bytecodeIndex < bytecode.len) {
            try interp.memory.store8(bytecode[bytecodeIndex], memoryIndex);
        } else {
            try interp.memory.store8(0x00, memoryIndex);
        }
    }

}
