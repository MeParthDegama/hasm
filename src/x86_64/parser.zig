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
            var r_tokens: ?[]Token = &[0]Token{};
            var r_tokens_loop_count: usize = 0;

            while (r_tokens) |t| {
                var parsed_line_tokens = self.parseLineType(if (r_tokens_loop_count == 0) toks else t);
                
                std.debug.print("{} {}: ", .{tokens_info.line_no, parsed_line_tokens.line_type});
                printToken(parsed_line_tokens.token);
                r_tokens = parsed_line_tokens.r_token;

                r_tokens_loop_count += 1;
            }

            tokens_info.tokens.deinit();
            return true;
        } else {
            return false;
        }
    }

    const ParseLineStruct = struct {
        token: []Token,
        line_type: LineType,
        r_token: ?[]Token,
    };

    const LineType = enum {
        LineModulo,
        LineLabel,
        LineInstruction,
        LineData,
        LineUnknow,
    };

    pub fn parseLineType(_: Self, toks: []Token) ParseLineStruct {
        var token_end: usize = toks.len;
        var line_type: LineType = .LineUnknow;

        for (toks, 0..) |tok, tok_index| {
            switch (tok_index) {
                0 => {
                    if (tok.token_type == .TokenModulo) {
                        token_end = toks.len;
                        line_type = .LineModulo;
                        break;
                    }
                },
                1 => {
                    if (tok.token_type == .TokenColon) {
                        token_end = tok_index + 1;
                        line_type = .LineLabel;
                        break;
                    }
                },
                else => {},
            }
        }

        return .{
            .token = toks[0..token_end],
            .line_type = line_type,
            .r_token = if (token_end == toks.len) null else toks[token_end..],
        };
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
