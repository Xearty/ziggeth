pub const Opcode = @import("evm_instructions").opcodes.Opcode;
pub const Interpreter = @import("interpreter.zig").Interpreter;
pub const execute = @import("execution.zig").execute;
pub const decompile = @import("decompiler.zig").decompile;
