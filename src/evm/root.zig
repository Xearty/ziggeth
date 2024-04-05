const instructions = @import("instructions.zig");

pub const Opcode = @import("opcodes.zig").Opcode;
pub const Instruction = instructions.Instruction;
pub const Context = @import("context.zig").Context;

pub const execute = @import("execution.zig").execute;
