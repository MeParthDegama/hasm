/// parser
const std = @import("std");
const String = @import("zigstr").String;
const Log = @import("ziglog");
const common = @import("../common.zig");

const Lexer = @import("./lexer.zig").Lexer;
const Token = @import("./lexer.zig").Token;

pub const Parser = struct {
    lexer: Lexer,
    var log: Log.Log = undefined;
    var err_count: i64 = 0;
    var warn_count: i64 = 0;

    const Self = @This();

    pub fn init(file_name: String) Self {
        log = Log.Log.init();

        return .{
            .lexer = Lexer.init(file_name),
        };
    }

    pub fn parse(self: *Self) void {
        while (self.next()) {}
        if (err_count != 0) {
            log.print();
            common.errExit();
        }
    }

    pub fn next(self: *Self) bool {
        var tokens_info = self.lexer.next();

        if (tokens_info.err) |err| {
            log.pushLog(err);
            err_count += 1;
        }

        if (tokens_info.warn) |warn| {
            log.pushLog(warn);
            warn_count += 1;
        }

        if (tokens_info.tokens.ptr) |toks| {
            printToken(toks);


            // make loop of parse tokne 
            // like recursen of parse line type function 
            // or make forward function, if parseLineTypeFwd
            // call this function and call next function
            // inside this function...
            self.parseLineType(toks);
            
            
            tokens_info.tokens.deinit();
            return true;
        } else {
            return false;
        }
    }

    pub fn parseLineType(_: Self, toks: []Token) void {
        for (toks, 0..) |tok, tok_index| {
            switch (tok_index) {
                1 => {
                    if (tok.token_type == .TokenColon) {
                        std.debug.print("this is lable\n", .{});
                    }
                },
                else => {},
            }
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
