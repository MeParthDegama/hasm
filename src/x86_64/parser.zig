/// parser
const std = @import("std");
const String = @import("zigstr").String;

const Lexer = @import("./lexer.zig").Lexer;
const Token = @import("./lexer.zig").Token;

pub const Parser = struct {
    lexer: Lexer,

    const Self = @This();

    pub fn init(file_name: String) Self {
        return .{
            .lexer = Lexer.init(file_name),
        };
    }

    pub fn parse(s: Self) void {
        while (s.next()) {
        
        }
    }

    pub fn next(s: Self) bool {
        var tokens = s.lexer.next();

        if (s.lexer.lexerLog().err_count != 0) {
            s.lexer.lexerLog().print();
            std.os.exit(2);
        }

        if (tokens) |toks| {
            printToken(toks);
            return true;
        } else {
            return false;
        }
    }

    pub fn printToken(toks: []Token) void {
        for (toks) |t| {
            std.debug.print("[{s}->{}]", .{ t.token_value.buffer orelse "nil", t.token_type });
        }
        std.debug.print("\n", .{});
    }

    pub fn deinit(_: Self) void {
        //
    }
};
