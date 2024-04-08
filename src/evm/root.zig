pub const Opcode = @import("evm_instructions").opcodes.Opcode;
pub const Interpreter = @import("Interpreter.zig");
pub const execute = @import("execution.zig").execute;
pub const decompile = @import("decompiler.zig").decompile;
pub const Host = @import("Host.zig");
pub const HostMock = @import("HostMock.zig");
