const std = @import("std");
const evm = @import("evm");
const Interpreter = evm.Interpreter;
const utils = @import("evm_utils");
const Word = @import("types").Word;
const Keccak256 = std.crypto.hash.sha3.Keccak256;

pub inline fn sha3(interp: *Interpreter) !void {
    const offset = interp.stack.pop();
    const length = interp.stack.pop();

    const bytes = interp.memory.get(@truncate(offset), @truncate(length));
    var hash: [32]u8 = undefined;
    Keccak256.hash(bytes, &hash, .{});
    try interp.stack.push(utils.intFromBigEndianBytes(Word, &hash));
}
