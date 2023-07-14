/// lexer
const std = @import("std");
const String = @import("zigstr").String;

const Log = @import("../log.zig").Log;
const make_Array = @import("../dynarray.zig").make_Array;

pub const TokenType = enum {
    TokenUnknow,
    TokenModulo,
    TokenColon,
    TokenComma,
    TokenSemiColon,
};

pub const Token = struct {
    token_value: String,
    token_type: TokenType,
};

pub const Lexer = struct {
    src_file: String,

    const Self = @This();
    var fileBuffer: []u8 = undefined;
    var currIndex: usize = 0;

    var log: Log = undefined;

    pub fn init(file_name: String) Self {
        log = Log.init();

        openFile(file_name);

        return Self{
            .src_file = file_name,
        };
    }

    var currLine: usize = 1;

    pub fn next(_: Self) ?[]Token {
        comptime var d_array = make_Array(Token);
        var token_stack = d_array.init();
        std.debug.print("{}\n", .{@TypeOf(token_stack)});

        var currToken: ?String = null;

        while (nextChar()) |c| {
            if (c == '\n') {
                currLine += 1;
                if (currToken) |ct| {
                    var to = Token{
                        .token_value = ct,
                        .token_type = .TokenUnknow,
                    };

                    if (ct.buffer != null) {
                        token_stack.push(to);
                    }
                }
                if (token_stack.ptr) |ptr| {
                    return ptr;
                } else {
                    continue;
                }
            }

            switch (c) {
                ' ' => {
                    if (currToken) |ct| {
                        if (ct.buffer != null) {
                            var to = Token{
                                .token_value = ct,
                                .token_type = .TokenUnknow,
                            };
                            token_stack.push(to);
                            currToken = String.init();
                        }
                    }
                },

                '%' => {
                    if (currToken) |ct| {
                        if (ct.buffer != null) {
                            var to = Token{
                                .token_value = ct,
                                .token_type = .TokenUnknow,
                            };
                            token_stack.push(to);
                            currToken = String.init();
                        }
                    }

                    token_stack.push(.{
                        .token_value = String.init(),
                        .token_type = .TokenModulo,
                    });
                },

                ':' => {
                    if (currToken) |ct| {
                        if (ct.buffer != null) {
                            var to = Token{
                                .token_value = ct,
                                .token_type = .TokenUnknow,
                            };
                            token_stack.push(to);
                            currToken = String.init();
                        }
                    }

                    token_stack.push(.{
                        .token_value = String.init(),
                        .token_type = .TokenColon,
                    });
                },

                ',' => {
                    if (currToken) |ct| {
                        if (ct.buffer != null) {
                            var to = Token{
                                .token_value = ct,
                                .token_type = .TokenUnknow,
                            };
                            token_stack.push(to);
                            currToken = String.init();
                        }
                    }

                    token_stack.push(.{
                        .token_value = String.init(),
                        .token_type = .TokenComma,
                    });
                },

                ';' => {
                    if (currToken) |ct| {
                        if (ct.buffer != null) {
                            var to = Token{
                                .token_value = ct,
                                .token_type = .TokenUnknow,
                            };
                            token_stack.push(to);
                            currToken = String.init();
                        }
                    }

                    while (nextChar() != '\n') {}

                    if (token_stack.ptr) |ptr| {
                        return ptr;
                    }
                },

                else => {
                    if (currToken) |*ct| {
                        ct.addChar(c);
                    } else {
                        currToken = String.init();
                        currToken.?.addChar(c);
                    }
                },
            }
        } else {
            if (currToken) |ct| {
                if (currToken.?.buffer != null) {
                    var to = Token{
                        .token_value = ct,
                        .token_type = .TokenUnknow,
                    };
                    token_stack.push(to);
                    currToken = String.init();
                }
            }

            if (token_stack.ptr) |ptr| {
                return ptr;
            }
        }

        return null;
    }

    fn addToken(s: make_Array(Token)) void {
        _ = s;
    }

    fn openFile(file_path: String) void {
        fileBuffer = std.fs.cwd().readFileAlloc(std.heap.page_allocator, file_path.get(), 1024 * 1000) catch |e| {
            if (e == error.FileNotFound) {
                log.err("file not found...", .{});
            } else {
                log.err("file open error...", .{});
            }

            return undefined;
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

    pub fn lexerLog(_: Self) Log {
        return log;
    }
};

test "lexer" {
    var l = Lexer.init("hello, world!");
    _ = l;
}
