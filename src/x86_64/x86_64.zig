// x86_64 / amd64 assembler interface

const std = @import("std");
const printInfoFn = @import("./info.zig").printInfo;
const String = @import("zigstr").String;

const assembleAsm = @import("./assemble.zig").assmeble;

pub const x86_64 = struct {
    root_src_file: String,

    const Self = @This();

    pub fn init() Self {
        return Self{
            .root_src_file = String.init(),
        };
    }

    pub fn setRootSrcFile(slef: *Self, src_file_path: String) void {
        slef.root_src_file = src_file_path;
    }

    pub fn assemble(_: *Self) !void {
        try assembleAsm();
    }

    pub fn printInfo() void {
        printInfoFn();
    }

    pub fn deinit(_: Self) void {}
};
