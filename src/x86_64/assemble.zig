/// assemble

const std = @import("std");

const lexer = @import("./lexer.zig").lexer;

pub fn assmeble() !void {

    try lexer();

}
