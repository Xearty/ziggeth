const std = @import("std");

const InstructionMetadata = struct {
    mnemonic: []const u8,
    opcode: u8,
    size: usize,
};

pub const instructions_metadata = [_]InstructionMetadata{
    .{
        .mnemonic = "STOP",
        .opcode = 0x00,
        .size = 1,
    },
    .{
        .mnemonic = "ADD",
        .opcode = 0x01,
        .size = 1,
    },
    .{
        .mnemonic = "MUL",
        .opcode = 0x02,
        .size = 1,
    },
    .{
        .mnemonic = "SUB",
        .opcode = 0x03,
        .size = 1,
    },
    .{
        .mnemonic = "DIV",
        .opcode = 0x04,
        .size = 1,
    },
    .{
        .mnemonic = "SDIV",
        .opcode = 0x05,
        .size = 1,
    },
    .{
        .mnemonic = "MOD",
        .opcode = 0x06,
        .size = 1,
    },
    .{
        .mnemonic = "SMOD",
        .opcode = 0x07,
        .size = 1,
    },
    .{
        .mnemonic = "ADDMOD",
        .opcode = 0x08,
        .size = 1,
    },
    .{
        .mnemonic = "MULMOD",
        .opcode = 0x09,
        .size = 1,
    },
    .{
        .mnemonic = "EXP",
        .opcode = 0x0a,
        .size = 1,
    },
    .{
        .mnemonic = "SIGNEXTEND",
        .opcode = 0x0b,
        .size = 1,
    },
    .{
        .mnemonic = "LT",
        .opcode = 0x10,
        .size = 1,
    },
    .{
        .mnemonic = "GT",
        .opcode = 0x11,
        .size = 1,
    },
    .{
        .mnemonic = "SLT",
        .opcode = 0x12,
        .size = 1,
    },
    .{
        .mnemonic = "SGT",
        .opcode = 0x13,
        .size = 1,
    },
    .{
        .mnemonic = "EQ",
        .opcode = 0x14,
        .size = 1,
    },
    .{
        .mnemonic = "ISZERO",
        .opcode = 0x15,
        .size = 1,
    },
    .{
        .mnemonic = "AND",
        .opcode = 0x16,
        .size = 1,
    },
    .{
        .mnemonic = "OR",
        .opcode = 0x17,
        .size = 1,
    },
    .{
        .mnemonic = "XOR",
        .opcode = 0x18,
        .size = 1,
    },
    .{
        .mnemonic = "NOT",
        .opcode = 0x19,
        .size = 1,
    },
    .{
        .mnemonic = "BYTE",
        .opcode = 0x1a,
        .size = 1,
    },
    .{
        .mnemonic = "SHL",
        .opcode = 0x1b,
        .size = 1,
    },
    .{
        .mnemonic = "SHR",
        .opcode = 0x1c,
        .size = 1,
    },
    .{
        .mnemonic = "SAR",
        .opcode = 0x1d,
        .size = 1,
    },
    .{
        .mnemonic = "POP",
        .opcode = 0x50,
        .size = 1,
    },
    .{
        .mnemonic = "SLOAD",
        .opcode = 0x54,
        .size = 1,
    },
    .{
        .mnemonic = "SSTORE",
        .opcode = 0x55,
        .size = 1,
    },
    .{
        .mnemonic = "JUMP",
        .opcode = 0x56,
        .size = 1,
    },
    .{
        .mnemonic = "JUMPI",
        .opcode = 0x57,
        .size = 1,
    },
    .{
        .mnemonic = "PC",
        .opcode = 0x58,
        .size = 1,
    },
} ++ genPushInstructionDefinitions()
  ++ genDupInstructionDefinitions()
  ++ genSwapInstructionDefinitions();

fn genPushInstructionDefinitions() [32]InstructionMetadata {
    var definitions: [32]InstructionMetadata = undefined;

    inline for (&definitions, 0..) |*def, index| def.* = .{
        .mnemonic = std.fmt.comptimePrint("PUSH{}", .{index + 1}),
        .opcode = 0x60 + index,
        .size = index + 2,
    };

    comptime return definitions;
}

fn genDupInstructionDefinitions() [16]InstructionMetadata {
    var definitions: [16]InstructionMetadata = undefined;

    inline for (&definitions, 0..) |*def, index| def.* = .{
        .mnemonic = std.fmt.comptimePrint("DUP{}", .{index + 1}),
        .opcode = 0x80 + index,
        .size = 1,
    };

    comptime return definitions;
}

fn genSwapInstructionDefinitions() [16]InstructionMetadata {
    var definitions: [16]InstructionMetadata = undefined;

    inline for (&definitions, 0..) |*def, index| def.* = .{
        .mnemonic = std.fmt.comptimePrint("SWAP{}", .{index + 1}),
        .opcode = 0x90 + index,
        .size = 1,
    };

    comptime return definitions;
}
