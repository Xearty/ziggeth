const std = @import("std");
const testing = std.testing;
const expect = testing.expect;

const evm = @import("evm");

fn basicValueTest(expected_value: u256, bytecode: []const u8) !void {
    var evm_context = evm.Context.init(std.testing.allocator);
    defer evm_context.deinit();

    try evm.executeBytecode(&evm_context, bytecode);
    try expect(evm_context.peek() == expected_value);
}

test "ADD instruction" {
    try basicValueTest(0x3, &.{
        @intFromEnum(evm.Opcode.PUSH1), 0x1,
        @intFromEnum(evm.Opcode.PUSH1), 0x2,
        @intFromEnum(evm.Opcode.ADD),
    });
}

test "MUL instruction" {
    try basicValueTest(0x25 * 0x53 * 0x31, &.{
        @intFromEnum(evm.Opcode.PUSH1), 0x25,
        @intFromEnum(evm.Opcode.PUSH1), 0x53,
        @intFromEnum(evm.Opcode.MUL),
        @intFromEnum(evm.Opcode.PUSH1), 0x31,
        @intFromEnum(evm.Opcode.MUL),
    });
}

test "ADD and MUL instructions" {
    try basicValueTest(0x9, &.{
        @intFromEnum(evm.Opcode.PUSH1), 0x1,
        @intFromEnum(evm.Opcode.PUSH1), 0x2,
        @intFromEnum(evm.Opcode.ADD),
        @intFromEnum(evm.Opcode.PUSH1), 0x3,
        @intFromEnum(evm.Opcode.MUL),
    });
}

test "STOP instruction" {
    try basicValueTest(0x3, &.{
        @intFromEnum(evm.Opcode.PUSH1), 0x1,
        @intFromEnum(evm.Opcode.PUSH1), 0x2,
        @intFromEnum(evm.Opcode.ADD),
        @intFromEnum(evm.Opcode.PUSH1), 0x3,
        @intFromEnum(evm.Opcode.STOP),
        @intFromEnum(evm.Opcode.MUL),
    });
}

test "SUB instruction" {
    try basicValueTest(0x6, &.{
        @intFromEnum(evm.Opcode.PUSH1), 0x1,
        @intFromEnum(evm.Opcode.PUSH1), 0x2,
        @intFromEnum(evm.Opcode.ADD),
        @intFromEnum(evm.Opcode.PUSH1), 0x9,
        @intFromEnum(evm.Opcode.SUB),
    });
}

test "DIV instruction" {
    try basicValueTest(0x3, &.{
        @intFromEnum(evm.Opcode.PUSH1), 0x1,
        @intFromEnum(evm.Opcode.PUSH1), 0x9,
        @intFromEnum(evm.Opcode.ADD),
        @intFromEnum(evm.Opcode.PUSH1), 0x20,
        @intFromEnum(evm.Opcode.DIV),
    });
}

test "MOD instruction" {
    try basicValueTest(3, &.{
        @intFromEnum(evm.Opcode.PUSH1), 5,
        @intFromEnum(evm.Opcode.PUSH1), 23,
        @intFromEnum(evm.Opcode.MOD),
    });
}

test "PUSH2 instruction" {
    try basicValueTest(3526993988, &.{
        @intFromEnum(evm.Opcode.PUSH2), 0x05, 0xad,
        @intFromEnum(evm.Opcode.PUSH2), 0xf7, 0x02,
        @intFromEnum(evm.Opcode.ADD),
        @intFromEnum(evm.Opcode.PUSH2), 0xd4, 0xfc,
        @intFromEnum(evm.Opcode.MUL),
    });
}