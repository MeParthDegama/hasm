/// assemble
const std = @import("std");
const String = @import("zigstr").String;

const Lexer = @import("./lexer.zig").Lexer;
const Parser = @import("./parser.zig").Parser;

pub fn assmeble(root_src_file: String) !void {
    
    var parsed_file = Parser.init(root_src_file);
    defer parsed_file.deinit();

    parsed_file.parse();

}
