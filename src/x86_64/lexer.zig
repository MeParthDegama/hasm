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

    pub fn next(_: Self) ?usize {
        if (currIndex == fileBuffer.len) {
            return null;
        }

        var c = currIndex;
        currIndex += 1;
        return c;
    }

    fn openFile(file_path: String) void {
        fileBuffer = std.fs.cwd().readFileAlloc(std.heap.page_allocator, file_path.get(), 1024 * 1000) catch {
            std.debug.print("file not found...\n", .{});
            std.os.exit(2);
        };
    }
};

test "lexer" {
    var l = Lexer.init("hello, world!");
    _ = l;
}
