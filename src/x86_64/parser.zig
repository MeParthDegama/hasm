/// parser
const std = @import("std");
const String = @import("zigstr").String;

const Lexer = @import("./lexer.zig").Lexer;

pub const Parser = struct {
    lexer: Lexer,

    const Self = @This();

    pub fn init(file_name: String) Self {
        return .{
            .lexer = Lexer.init(file_name),
        };
    }

    pub fn parse(s: Self) void {
        s.next();
    }

    pub fn next(s: Self) void {
        s.lexer.next();

        if (s.lexer.lexerLog().err_count != 0) {
            s.lexer.lexerLog().print();
        }
    }

    pub fn deinit(_: Self) void {
        //
    }
};
