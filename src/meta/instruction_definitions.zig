const std = @import("std");
const Word = @import("constants").Word;

const InstructionDefinition = struct {
    mnemonic: []const u8,
    opcode: u8,
    size: usize,
    payload_type: type,
};

pub const instruction_definitions = [_]InstructionDefinition{
    .{
        .mnemonic = "STOP",
        .opcode = 0x00,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "ADD",
        .opcode = 0x01,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "MUL",
        .opcode = 0x02,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "SUB",
        .opcode = 0x03,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "DIV",
        .opcode = 0x04,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "SDIV",
        .opcode = 0x05,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "MOD",
        .opcode = 0x06,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "SMOD",
        .opcode = 0x07,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "ADDMOD",
        .opcode = 0x08,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "MULMOD",
        .opcode = 0x09,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "EXP",
        .opcode = 0x0a,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "SIGNEXTEND",
        .opcode = 0x0b,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "LT",
        .opcode = 0x10,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "GT",
        .opcode = 0x11,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "SLT",
        .opcode = 0x12,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "SGT",
        .opcode = 0x13,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "EQ",
        .opcode = 0x14,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "ISZERO",
        .opcode = 0x15,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "AND",
        .opcode = 0x16,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "OR",
        .opcode = 0x17,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "XOR",
        .opcode = 0x18,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "NOT",
        .opcode = 0x19,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "BYTE",
        .opcode = 0x1a,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "SHL",
        .opcode = 0x1b,
        .size = 1,
        .payload_type = void,
    },
    .{
        .mnemonic = "SHR",
        .opcode = 0x1c,
        .size = 1,
        .payload_type = void,
    },
} ++ genPushInstructionDefinitions()
  ++ genDupInstructionDefinitions()
  ++ genSwapInstructionDefinitions();

fn genPushInstructionDefinitions() [32]InstructionDefinition {
    const PushInstructionType = struct { value: Word };
    var definitions: [32]InstructionDefinition = undefined;

    inline for (&definitions, 0..) |*def, index| def.* = .{
        .mnemonic = std.fmt.comptimePrint("PUSH{}", .{index + 1}),
        .opcode = 0x60 + index,
        .size = index + 2,
        .payload_type = PushInstructionType,
    };

    comptime return definitions;
}

fn genDupInstructionDefinitions() [16]InstructionDefinition {
    var definitions: [16]InstructionDefinition = undefined;

    inline for (&definitions, 0..) |*def, index| def.* = .{
        .mnemonic = std.fmt.comptimePrint("DUP{}", .{index + 1}),
        .opcode = 0x80 + index,
        .size = 1,
        .payload_type = void,
    };

    comptime return definitions;
}

fn genSwapInstructionDefinitions() [16]InstructionDefinition {
    var definitions: [16]InstructionDefinition = undefined;

    inline for (&definitions, 0..) |*def, index| def.* = .{
        .mnemonic = std.fmt.comptimePrint("SWAP{}", .{index + 1}),
        .opcode = 0x90 + index,
        .size = 1,
        .payload_type = void,
    };

    comptime return definitions;
}
