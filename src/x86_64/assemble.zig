/// assemble
const std = @import("std");
const String = @import("zigstr").String;

const Lexer = @import("./lexer.zig").Lexer;

pub fn assmeble(root_src_file: String) !void {
    const lexering_file = Lexer.init(root_src_file);
    _ = lexering_file;
}
