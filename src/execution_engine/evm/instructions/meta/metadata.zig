const std = @import("std");

const InstructionMetadata = struct {
    mnemonic: []const u8,
    opcode: u8,
};

pub const instructions_metadata = [_]InstructionMetadata{
    // Stop and arithmetic operations
    .{ .mnemonic = "STOP",         .opcode = 0x00, },
    .{ .mnemonic = "ADD",          .opcode = 0x01, },
    .{ .mnemonic = "MUL",          .opcode = 0x02, },
    .{ .mnemonic = "SUB",          .opcode = 0x03, },
    .{ .mnemonic = "DIV",          .opcode = 0x04, },
    .{ .mnemonic = "SDIV",         .opcode = 0x05, },
    .{ .mnemonic = "MOD",          .opcode = 0x06, },
    .{ .mnemonic = "SMOD",         .opcode = 0x07, },
    .{ .mnemonic = "ADDMOD",       .opcode = 0x08, },
    .{ .mnemonic = "MULMOD",       .opcode = 0x09, },
    .{ .mnemonic = "EXP",          .opcode = 0x0a, },
    .{ .mnemonic = "SIGNEXTEND",   .opcode = 0x0b, },
    // Comparison & Bitwise Logic Operations
    .{ .mnemonic = "LT",           .opcode = 0x10, },
    .{ .mnemonic = "GT",           .opcode = 0x11, },
    .{ .mnemonic = "SLT",          .opcode = 0x12, },
    .{ .mnemonic = "SGT",          .opcode = 0x13, },
    .{ .mnemonic = "EQ",           .opcode = 0x14, },
    .{ .mnemonic = "ISZERO",       .opcode = 0x15, },
    .{ .mnemonic = "AND",          .opcode = 0x16, },
    .{ .mnemonic = "OR",           .opcode = 0x17, },
    .{ .mnemonic = "XOR",          .opcode = 0x18, },
    .{ .mnemonic = "NOT",          .opcode = 0x19, },
    .{ .mnemonic = "BYTE",         .opcode = 0x1a, },
    .{ .mnemonic = "SHL",          .opcode = 0x1b, },
    .{ .mnemonic = "SHR",          .opcode = 0x1c, },
    .{ .mnemonic = "SAR",          .opcode = 0x1d, },
    // SHA3
    .{ .mnemonic = "KECCAK256",    .opcode = 0x20, },
    // Environmental Information
    .{ .mnemonic = "CALLVALUE",    .opcode = 0x34, },
    .{ .mnemonic = "CALLDATALOAD", .opcode = 0x35, },
    .{ .mnemonic = "CALLDATASIZE", .opcode = 0x36, },
    .{ .mnemonic = "CALLDATACOPY", .opcode = 0x37, },
    .{ .mnemonic = "CODESIZE",     .opcode = 0x38, },
    .{ .mnemonic = "CODECOPY",     .opcode = 0x39, },
    .{ .mnemonic = "EXTCODESIZE",  .opcode = 0x3b, },
    .{ .mnemonic = "EXTCODECOPY",  .opcode = 0x3c, },
    .{ .mnemonic = "EXTCODEHASH",  .opcode = 0x3f, },
    // Block Information
    // Stack Memory Storage and Flow Operations
    .{ .mnemonic = "POP",          .opcode = 0x50, },
    .{ .mnemonic = "MLOAD",        .opcode = 0x51, },
    .{ .mnemonic = "MSTORE",       .opcode = 0x52, },
    .{ .mnemonic = "MSTORE8",      .opcode = 0x53, },
    .{ .mnemonic = "SLOAD",        .opcode = 0x54, },
    .{ .mnemonic = "SSTORE",       .opcode = 0x55, },
    .{ .mnemonic = "JUMP",         .opcode = 0x56, },
    .{ .mnemonic = "JUMPI",        .opcode = 0x57, },
    .{ .mnemonic = "PC",           .opcode = 0x58, },
    .{ .mnemonic = "MSIZE",        .opcode = 0x59, },
    .{ .mnemonic = "JUMPDEST",     .opcode = 0x5b, },
    // Logging Operations
    // System Operations
    .{ .mnemonic = "RETURN",       .opcode = 0xf3, },
    .{ .mnemonic = "REVERT",       .opcode = 0xfd, }, // placeholder
    .{ .mnemonic = "INVALID",      .opcode = 0xfe, },
} ++ genPushInstructionDefinitions()
  ++ genDupInstructionDefinitions()
  ++ genSwapInstructionDefinitions();

fn genPushInstructionDefinitions() [33]InstructionMetadata {
    var definitions: [33]InstructionMetadata = undefined;

    inline for (&definitions, 0..) |*def, index| def.* = .{
        .mnemonic = std.fmt.comptimePrint("PUSH{}", .{index}),
        .opcode = 0x5f + index,
    };

    comptime return definitions;
}

fn genDupInstructionDefinitions() [16]InstructionMetadata {
    var definitions: [16]InstructionMetadata = undefined;

    inline for (&definitions, 0..) |*def, index| def.* = .{
        .mnemonic = std.fmt.comptimePrint("DUP{}", .{index + 1}),
        .opcode = 0x80 + index,
    };

    comptime return definitions;
}

fn genSwapInstructionDefinitions() [16]InstructionMetadata {
    var definitions: [16]InstructionMetadata = undefined;

    inline for (&definitions, 0..) |*def, index| def.* = .{
        .mnemonic = std.fmt.comptimePrint("SWAP{}", .{index + 1}),
        .opcode = 0x90 + index,
    };

    comptime return definitions;
}
