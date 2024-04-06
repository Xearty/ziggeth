const std = @import("std");
pub const opcodes = @import("opcodes.zig");

pub usingnamespace @import("definitions/arithmetic.zig");
pub usingnamespace @import("definitions/comparison.zig");
pub usingnamespace @import("definitions/bitwise.zig");
pub usingnamespace @import("definitions/stack.zig");
pub usingnamespace @import("definitions/state.zig");
pub usingnamespace @import("definitions/host.zig");

// returns the unquantified tag
pub fn isQuantified(comptime opcode: opcodes.Opcode) ?[]const u8 {
    comptime {
        const quantified_instructions = [_][]const u8 { "PUSH", "DUP", "SWAP" };
        for (quantified_instructions) |prefix| {
            if (std.mem.startsWith(u8, @tagName(opcode), prefix)) {
                return prefix;
            }
        }
        return null;
    }
}

pub fn extractQuantity(comptime opcode: opcodes.Opcode) u32 {
    comptime {
        std.debug.assert(isQuantified(opcode) != null);
        var mnemonic: []const u8 = @tagName(opcode);
        while (!std.ascii.isDigit(mnemonic[0])) {
            mnemonic = mnemonic[1..];
        }
        return std.fmt.parseInt(u32, mnemonic, 10) catch unreachable;
    }
}

pub fn getSize(opcode: opcodes.Opcode) usize {
    const defs = @import("meta/metadata.zig").instructions_metadata;

    return switch (opcode) {
        inline else => |tag| blk: {
            inline for (defs) |def| {
                @setEvalBranchQuota(10000);
                if (comptime @intFromEnum(tag) == def.opcode) {
                    break :blk def.size;
                }
            }
        },
    };
}
