/// lexer
const std = @import("std");
const String = @import("zigstr").String;

const Log = @import("../log.zig").Log;

const TokenType = enum {};

const Token = struct {
    token_value: String,
    token_type: TokenType,
};

pub const Lexer = struct {
    src_file: String,

    const Self = @This();
    var fileBuffer: []u8 = undefined;
    var currIndex: usize = 0;

    var log: Log = undefined;

    pub fn init(file_name: String) Self {
        log = Log.init();

        openFile(file_name);

        return Self{
            .src_file = file_name,
        };
    }

    pub fn next(_: Self) void {
        while (nextChar()) |c| {
            std.debug.print("{c}", .{c});
        }
    }

    fn openFile(file_path: String) void {
        fileBuffer = std.fs.cwd().readFileAlloc(std.heap.page_allocator, file_path.get(), 1024 * 1000) catch |e| {
            if (e == error.FileNotFound) {
                log.err("file not found...", .{});
            } else {
                log.err("file open error...", .{});
            }

            return undefined;
        };
    }

    fn nextChar() ?u8 {
        if (currIndex == fileBuffer.len) {
            return null;
        }
        var nIndex = currIndex;
        currIndex += 1;
        return fileBuffer[nIndex];
    }

    pub fn lexerLog(_: Self) Log {
        return log;
    }
};

test "lexer" {
    var l = Lexer.init("hello, world!");
    _ = l;
}
