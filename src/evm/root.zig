pub const Opcode = @import("evm_instructions").opcodes.Opcode;
pub const Context = @import("context.zig").Context;
pub const execute = @import("execution.zig").execute;
pub const decompile = @import("decompiler.zig").decompile;
