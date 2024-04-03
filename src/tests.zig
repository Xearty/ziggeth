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

test "PUSH3 instruction" {
    try basicValueTest(4849358562, &.{
        @intFromEnum(evm.Opcode.PUSH3), 0x23, 0xe0, 0x93,
        @intFromEnum(evm.Opcode.PUSH3), 0x67, 0x79, 0x43,
        @intFromEnum(evm.Opcode.ADD),
        @intFromEnum(evm.Opcode.PUSH3), 0x00, 0x02, 0x13,
        @intFromEnum(evm.Opcode.MUL),
    });
}

test "PUSH32 instruction" {
    try basicValueTest(85970811241406490303390531509016784217088394200819083899633365944276094183929, &.{
        @intFromEnum(evm.Opcode.PUSH32),
        0x70, 0x80, 0x48, 0xe2,
        0x39, 0xd9, 0xf4, 0x5b,
        0x12, 0x6e, 0x12, 0xca,
        0x88, 0x34, 0x8d, 0xc0,
        0x05, 0xf1, 0xbd, 0x4b,
        0x3c, 0x66, 0x08, 0x01,
        0xb8, 0xeb, 0x42, 0x5f,
        0x57, 0x08, 0xfd, 0xe2,
        @intFromEnum(evm.Opcode.PUSH32),
        0x4d, 0x91, 0x78, 0x58,
        0x22, 0xda, 0x1d, 0x2c,
        0x25, 0x44, 0xea, 0x96,
        0x20, 0x4b, 0x72, 0x47, 
        0xbf, 0x7f, 0x15, 0x9b,
        0xd9, 0x0b, 0xbb, 0x80,
        0xa5, 0x5e, 0xc6, 0x63,
        0x1e, 0x49, 0x6c, 0x17,
        @intFromEnum(evm.Opcode.ADD),
    });
}

test "DUP1 instruction" {
    try basicValueTest(25, &.{
        @intFromEnum(evm.Opcode.PUSH1), 0x5,
        @intFromEnum(evm.Opcode.DUP1),
        @intFromEnum(evm.Opcode.MUL),
    });
}

test "DUP2 instruction" {
    try basicValueTest(48, &.{
        @intFromEnum(evm.Opcode.PUSH1), 0x5,
        @intFromEnum(evm.Opcode.PUSH1), 0x8,
        @intFromEnum(evm.Opcode.PUSH1), 0x6,
        @intFromEnum(evm.Opcode.DUP2),
        @intFromEnum(evm.Opcode.MUL),
    });
}

test "DUP3 instruction" {
    try basicValueTest(30, &.{
        @intFromEnum(evm.Opcode.PUSH1), 0x5,
        @intFromEnum(evm.Opcode.PUSH1), 0x8,
        @intFromEnum(evm.Opcode.PUSH1), 0x6,
        @intFromEnum(evm.Opcode.DUP3),
        @intFromEnum(evm.Opcode.MUL),
    });
}