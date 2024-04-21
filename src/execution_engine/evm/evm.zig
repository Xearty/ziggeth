pub const Opcode = @import("./instructions/opcodes.zig").Opcode;
pub const Interpreter = @import("Interpreter.zig");
pub const decompile = @import("decompiler.zig").decompile;
pub const Host = @import("Host.zig");
pub const VolatileHost = @import("VolatileHost.zig");
