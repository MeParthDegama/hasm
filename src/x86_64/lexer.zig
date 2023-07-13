/// lexer
const std = @import("std");

const String = @import("zigstr").String;

pub const Lexer = struct {
    src_file: String,

    const Self = @This();
    var fileBuffer: []u8 = undefined;
    var currIndex: usize = 0;

    pub fn init(file_name: String) Self {
        openFile(file_name);

        return Self{
            .src_file = file_name,
        };
    }

    pub fn next(_: Self) void {
        while (nextChar()) |c| {
            std.debug.print("{}", .{c});
        }
    }

    fn openFile(file_path: String) void {
        fileBuffer = std.fs.cwd().readFileAlloc(std.heap.page_allocator, file_path.get(), 1024 * 1000) catch |e| {
            if (e == error.FileNotFound) {
                std.debug.print("file not found...\n", .{});
                std.os.exit(2);
            } else {
                std.debug.print("other error...\n", .{});
                std.os.exit(2);
            }
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
};

test "lexer" {
    var l = Lexer.init("hello, world!");
    _ = l;
}
