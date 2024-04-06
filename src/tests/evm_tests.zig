const std = @import("std");
const Word = @import("constants").Word;
const SignedWord = @import("constants").SignedWord;
const testing_utils = @import("test_utils.zig");
const op = testing_utils.op;
const basicValueTest = testing_utils.basicValueTest;


test "ADD instruction" {
    try basicValueTest(0x3, &.{
        op(.PUSH1), 0x1,
        op(.PUSH1), 0x2,
        op(.ADD),
    });
}

test "MUL instruction" {
    try basicValueTest(0x25 * 0x53 * 0x31, &.{
        op(.PUSH1), 0x25,
        op(.PUSH1), 0x53,
        op(.MUL),
        op(.PUSH1), 0x31,
        op(.MUL),
    });
}

test "ADD and MUL instructions" {
    try basicValueTest(0x9, &.{
        op(.PUSH1), 0x1,
        op(.PUSH1), 0x2,
        op(.ADD),
        op(.PUSH1), 0x3,
        op(.MUL),
    });
}

test "STOP instruction" {
    try basicValueTest(0x3, &.{
        op(.PUSH1), 0x1,
        op(.PUSH1), 0x2,
        op(.ADD),
        op(.PUSH1), 0x3,
        op(.STOP),
        op(.MUL),
    });
}

test "SUB instruction" {
    try basicValueTest(0x6, &.{
        op(.PUSH1), 0x1,
        op(.PUSH1), 0x2,
        op(.ADD),
        op(.PUSH1), 0x9,
        op(.SUB),
    });
}

test "DIV instruction" {
    try basicValueTest(0x3, &.{
        op(.PUSH1), 0x1,
        op(.PUSH1), 0x9,
        op(.ADD),
        op(.PUSH1), 0x20,
        op(.DIV),
    });
}

test "MOD instruction" {
    try basicValueTest(3, &.{
        op(.PUSH1), 5,
        op(.PUSH1), 23,
        op(.MOD),
    });
}

test "PUSH2 instruction" {
    try basicValueTest(3526993988, &.{
        op(.PUSH2), 0x05, 0xad,
        op(.PUSH2), 0xf7, 0x02,
        op(.ADD),
        op(.PUSH2), 0xd4, 0xfc,
        op(.MUL),
    });
}

test "PUSH3 instruction" {
    try basicValueTest(4849358562, &.{
        op(.PUSH3), 0x23, 0xe0, 0x93,
        op(.PUSH3), 0x67, 0x79, 0x43,
        op(.ADD),
        op(.PUSH3), 0x00, 0x02, 0x13,
        op(.MUL),
    });
}

test "PUSH32 instruction" {
    try basicValueTest(85970811241406490303390531509016784217088394200819083899633365944276094183929, &.{
        op(.PUSH32),
        0x70, 0x80, 0x48, 0xe2,
        0x39, 0xd9, 0xf4, 0x5b,
        0x12, 0x6e, 0x12, 0xca,
        0x88, 0x34, 0x8d, 0xc0,
        0x05, 0xf1, 0xbd, 0x4b,
        0x3c, 0x66, 0x08, 0x01,
        0xb8, 0xeb, 0x42, 0x5f,
        0x57, 0x08, 0xfd, 0xe2,
        op(.PUSH32),
        0x4d, 0x91, 0x78, 0x58,
        0x22, 0xda, 0x1d, 0x2c,
        0x25, 0x44, 0xea, 0x96,
        0x20, 0x4b, 0x72, 0x47,
        0xbf, 0x7f, 0x15, 0x9b,
        0xd9, 0x0b, 0xbb, 0x80,
        0xa5, 0x5e, 0xc6, 0x63,
        0x1e, 0x49, 0x6c, 0x17,
        op(.ADD),
    });
}

test "DUP1 instruction" {
    try basicValueTest(25, &.{
        op(.PUSH1), 0x5,
        op(.DUP1),
        op(.MUL),
    });
}

test "DUP2 instruction" {
    try basicValueTest(48, &.{
        op(.PUSH1), 0x5,
        op(.PUSH1), 0x8,
        op(.PUSH1), 0x6,
        op(.DUP2),
        op(.MUL),
    });
}

test "DUP3 instruction" {
    try basicValueTest(30, &.{
        op(.PUSH1), 0x5,
        op(.PUSH1), 0x8,
        op(.PUSH1), 0x6,
        op(.DUP3),
        op(.MUL),
    });
}

test "SWAP1 instruction" {
    try basicValueTest(10, &.{
        op(.PUSH1), 0x2,
        op(.PUSH1), 0x1,
        op(.SWAP1),
        op(.PUSH1), 0x5,
        op(.MUL),
    });
}

test "SWAP2 instruction" {
    try basicValueTest(20, &.{
        op(.PUSH1), 0x4,
        op(.PUSH1), 0x2,
        op(.PUSH1), 0x1,
        op(.SWAP2),
        op(.PUSH1), 0x5,
        op(.MUL),
    });
}

test "SDIV instruction" {
    try basicValueTest(@as(Word, @bitCast(@as(SignedWord, -2))), &.{
        op(.PUSH32),
        0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff,
        op(.PUSH1), 0x2,
        op(.SDIV),
    });
}

test "EXP instruction" {
    try basicValueTest(4782969, &.{
        op(.PUSH1), 0x7,
        op(.PUSH1), 0x9,
        op(.EXP),
    });
}

test "EXP instruction exponent 0" {
    try basicValueTest(1, &.{
        op(.PUSH1), 0x0,
        op(.PUSH32),
        0x70, 0x80, 0x48, 0xe2,
        0x39, 0xd9, 0xf4, 0x5b,
        0x12, 0x6e, 0x12, 0xca,
        0x88, 0x34, 0x8d, 0xc0,
        0x05, 0xf1, 0xbd, 0x4b,
        0x3c, 0x66, 0x08, 0x01,
        0xb8, 0xeb, 0x42, 0x5f,
        0x57, 0x08, 0xfd, 0xe2,
        op(.EXP),
    });
}

test "EXP instruction exponent 1" {
    try basicValueTest(50885698490394846300529650755160262542539216671430528467191833472526591786466, &.{
        op(.PUSH1), 0x1,
        op(.PUSH32),
        0x70, 0x80, 0x48, 0xe2,
        0x39, 0xd9, 0xf4, 0x5b,
        0x12, 0x6e, 0x12, 0xca,
        0x88, 0x34, 0x8d, 0xc0,
        0x05, 0xf1, 0xbd, 0x4b,
        0x3c, 0x66, 0x08, 0x01,
        0xb8, 0xeb, 0x42, 0x5f,
        0x57, 0x08, 0xfd, 0xe2,
        op(.EXP),
    });
}

test "EXP instruction exponent 2" {
    try basicValueTest(11978948873077291082614935807129539229662568818552917922358889902544049961860, &.{
        op(.PUSH1), 0x2,
        op(.PUSH32),
        0x70, 0x80, 0x48, 0xe2,
        0x39, 0xd9, 0xf4, 0x5b,
        0x12, 0x6e, 0x12, 0xca,
        0x88, 0x34, 0x8d, 0xc0,
        0x05, 0xf1, 0xbd, 0x4b,
        0x3c, 0x66, 0x08, 0x01,
        0xb8, 0xeb, 0x42, 0x5f,
        0x57, 0x08, 0xfd, 0xe2,
        op(.EXP),
    });
}

test "EXP instruction exponent 3" {
    try basicValueTest(37345024310738433181113357916941771707155294456053137591045008100969753247368, &.{
        op(.PUSH1), 0x3,
        op(.PUSH32),
        0x70, 0x80, 0x48, 0xe2,
        0x39, 0xd9, 0xf4, 0x5b,
        0x12, 0x6e, 0x12, 0xca,
        0x88, 0x34, 0x8d, 0xc0,
        0x05, 0xf1, 0xbd, 0x4b,
        0x3c, 0x66, 0x08, 0x01,
        0xb8, 0xeb, 0x42, 0x5f,
        0x57, 0x08, 0xfd, 0xe2,
        op(.EXP),
    });
}

test "EXP instruction exponent 4" {
    try basicValueTest(20779191417530337471435148661939714880243222816637389320675012265821831961616, &.{
        op(.PUSH1), 0x4,
        op(.PUSH32),
        0x70, 0x80, 0x48, 0xe2,
        0x39, 0xd9, 0xf4, 0x5b,
        0x12, 0x6e, 0x12, 0xca,
        0x88, 0x34, 0x8d, 0xc0,
        0x05, 0xf1, 0xbd, 0x4b,
        0x3c, 0x66, 0x08, 0x01,
        0xb8, 0xeb, 0x42, 0x5f,
        0x57, 0x08, 0xfd, 0xe2,
        op(.EXP),
    });
}

test "EXP instruction exponent 5" {
    try basicValueTest(60623049136096303768541319095352851060905021887177462200724055449315697792544, &.{
        op(.PUSH1), 0x5,
        op(.PUSH32),
        0x70, 0x80, 0x48, 0xe2,
        0x39, 0xd9, 0xf4, 0x5b,
        0x12, 0x6e, 0x12, 0xca,
        0x88, 0x34, 0x8d, 0xc0,
        0x05, 0xf1, 0xbd, 0x4b,
        0x3c, 0x66, 0x08, 0x01,
        0xb8, 0xeb, 0x42, 0x5f,
        0x57, 0x08, 0xfd, 0xe2,
        op(.EXP),
    });
}

test "EXP instruction exponent 255" {
    try basicValueTest(57896044618658097711785492504343953926634992332820282019728792003956564819968, &.{
        op(.PUSH1), 0xff,
        op(.PUSH32),
        0x70, 0x80, 0x48, 0xe2,
        0x39, 0xd9, 0xf4, 0x5b,
        0x12, 0x6e, 0x12, 0xca,
        0x88, 0x34, 0x8d, 0xc0,
        0x05, 0xf1, 0xbd, 0x4b,
        0x3c, 0x66, 0x08, 0x01,
        0xb8, 0xeb, 0x42, 0x5f,
        0x57, 0x08, 0xfd, 0xe2,
        op(.EXP),
    });
}

test "EXP instruction exponent 256" {
    try basicValueTest(0, &.{
        op(.PUSH2), 0x01, 0x00,
        op(.PUSH32),
        0x70, 0x80, 0x48, 0xe2,
        0x39, 0xd9, 0xf4, 0x5b,
        0x12, 0x6e, 0x12, 0xca,
        0x88, 0x34, 0x8d, 0xc0,
        0x05, 0xf1, 0xbd, 0x4b,
        0x3c, 0x66, 0x08, 0x01,
        0xb8, 0xeb, 0x42, 0x5f,
        0x57, 0x08, 0xfd, 0xe2,
        op(.EXP),
    });
}

test "SIGNEXTEND instruction" {
    try basicValueTest(115792082335569848633007197573932045576244532214550284317904613665618839272930, &.{
        op(.PUSH12),
        0x3c, 0x66, 0x08, 0x01,
        0xb8, 0xeb, 0x42, 0x5f,
        0x57, 0x08, 0xfd, 0xe2,
        op(.PUSH1), 28,
        op(.SIGNEXTEND),
    });
}

test "LT instruction true" {
    try basicValueTest(1, &.{
        op(.PUSH1), 93,
        op(.PUSH1), 58,
        op(.LT),
    });
}

test "LT instruction false" {
    try basicValueTest(0, &.{
        op(.PUSH1), 58,
        op(.PUSH1), 93,
        op(.LT),
    });
}

test "GT instruction true" {
    try basicValueTest(1, &.{
        op(.PUSH1), 58,
        op(.PUSH1), 93,
        op(.GT),
    });
}

test "GT instruction false" {
    try basicValueTest(0, &.{
        op(.PUSH1), 93,
        op(.PUSH1), 58,
        op(.GT),
    });
}

test "EQ instruction true" {
    try basicValueTest(1, &.{
        op(.PUSH1), 58,
        op(.PUSH1), 58,
        op(.EQ),
    });
}

test "EQ instruction false" {
    try basicValueTest(0, &.{
        op(.PUSH1), 93,
        op(.PUSH1), 58,
        op(.EQ),
    });
}

test "ISZERO instruction true" {
    try basicValueTest(0, &.{
        op(.PUSH1), 0x69,
        op(.ISZERO),
    });
}

test "ISZERO instruction false" {
    try basicValueTest(1, &.{
        op(.PUSH1), 0x0,
        op(.ISZERO),
    });
}

test "BYTE instruction 29th byte" {
    try basicValueTest(1, &.{
        op(.PUSH3), 0x1, 0x2, 0x3,
        op(.PUSH1), 29,
        op(.BYTE),
    });
}

test "BYTE instruction 30th byte" {
    try basicValueTest(2, &.{
        op(.PUSH3), 0x1, 0x2, 0x3,
        op(.PUSH1), 30,
        op(.BYTE),
    });
}

test "BYTE instruction 31th byte" {
    try basicValueTest(3, &.{
        op(.PUSH3), 0x1, 0x2, 0x3,
        op(.PUSH1), 31,
        op(.BYTE),
    });
}

test "SHL instruction shift 1" {
    try basicValueTest(6, &.{
        op(.PUSH1), 0x3,
        op(.PUSH1), 1,
        op(.SHL),
    });
}

test "SHL instruction shift 8" {
    try basicValueTest(768, &.{
        op(.PUSH1), 0x3,
        op(.PUSH1), 8,
        op(.SHL),
    });
}

