/// lexer
const std = @import("std");
const String = @import("zigstr").String;
const Log = @import("../log.zig");
const initArray = @import("../dynarray.zig").initArray;
const config = @import("../config.zig");

pub const TokenType = enum {
    TokenUnknow,
    TokenModulo,
    TokenColon,
    TokenComma,
    TokenSemiColon,
    TokenString,
};

pub const Token = struct {
    token_value: String,
    token_type: TokenType,
};

pub const TokensInfo = struct {
    tokens: ?[]Token,
    err: ?Log.LogInfo,
};

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

    var curr_line: usize = 1;

    pub fn next(_: Self) TokensInfo {
        comptime var d_array = initArray(Token);
        var token_stack = d_array.init();

        var curr_token: ?String = null;

        var string_is_start = false;

        var err: ?Log.LogInfo = null;

        while (nextChar()) |c| {
            if (c == '\n') {
                curr_line += 1;

                addCurrentToken(&token_stack, &curr_token, .TokenUnknow);

                if (token_stack.ptr) |ptr| {
                    return .{
                        .tokens = ptr,
                        .err = err,
                    };
                } else {
                    continue;
                }
            }

            if (string_is_start) {
                if (c != '"') {
                    if (curr_token) |*ct| {
                        ct.addChar(c);
                    } else {
                        curr_token = String.init();
                        curr_token.?.addChar(c);
                    }
                    continue;
                }
            }

            switch (c) {
                ' ' => {
                    addCurrentToken(&token_stack, &curr_token, .TokenUnknow);
                },

                '%' => {
                    addCurrentToken(&token_stack, &curr_token, .TokenUnknow);
                    addNullToken(&token_stack, .TokenModulo);
                },

                ':' => {
                    addCurrentToken(&token_stack, &curr_token, .TokenUnknow);
                    addNullToken(&token_stack, .TokenColon);
                },

                ',' => {
                    addCurrentToken(&token_stack, &curr_token, .TokenUnknow);
                    addNullToken(&token_stack, TokenType.TokenComma);

                    err = makeErr("{}: , test err", .{curr_line});
                },

                ';' => {
                    addCurrentToken(&token_stack, &curr_token, .TokenUnknow);

                    while (nextChar() != '\n') {} else {
                        curr_line += 1;
                    }

                    if (token_stack.ptr) |ptr| {
                        return .{
                            .tokens = ptr,
                            .err = err,
                        };
                    }
                },

                '"' => {
                    string_is_start = !string_is_start;
                    if (!string_is_start) {
                        addCurrentToken(&token_stack, &curr_token, .TokenString);
                    }
                },

                else => {
                    if (curr_token) |*ct| {
                        ct.addChar(c);
                    } else {
                        curr_token = String.init();
                        curr_token.?.addChar(c);
                    }
                },
            }
        } else {
            addCurrentToken(&token_stack, &curr_token, .TokenUnknow);

            if (token_stack.ptr) |ptr| {
                return .{
                    .tokens = ptr,
                    .err = err,
                };
            }
        }

        return .{
            .tokens = null,
            .err = err,
        };
    }

    fn addCurrentToken(token_stack: *initArray(Token), current_token: *?String, token_type: TokenType) void {
        if (current_token.*) |ct| {
            if (ct.buffer != null) {
                var to = Token{
                    .token_value = ct,
                    .token_type = token_type,
                };
                token_stack.push(to);
                current_token.* = String.init();
            }
        }
    }

    fn addNullToken(token_stack: *initArray(Token), token_type: TokenType) void {
        token_stack.push(.{
            .token_value = String.init(),
            .token_type = token_type,
        });
    }

    fn nextChar() ?u8 {
        if (currIndex == fileBuffer.len) {
            return null;
        }
        var nIndex = currIndex;
        currIndex += 1;
        return fileBuffer[nIndex];
    }

    fn openFile(file_path: String) void {
        fileBuffer = std.fs.cwd().readFileAlloc(std.heap.page_allocator, file_path.get(), 1024 * 1000) catch |e| {
            if (e == error.FileNotFound) {
                printErrorAndExit("file not found...", .{});
            } else {
                printErrorAndExit("file open error...", .{});
            }

            return undefined;
        };
    }

    fn makeErr(comptime fmt: []const u8, args: anytype) Log.LogInfo {
        var err_log = Log.Log.init();
        return err_log.makeLog(fmt, args, .Err);
    }

    fn printErrorAndExit(comptime fmt: []const u8, args: anytype) void {
        var err_log = Log.Log.init();
        err_log.addLog(fmt, args, .Err);
        err_log.print();
        std.os.exit(comptime if (config.dev_mode) 0 else 2);
    }
};

test "lexer" {
    var l = Lexer.init("hello, world!");
    _ = l;
}
