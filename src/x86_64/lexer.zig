/// lexer
const std = @import("std");
const String = @import("zigstr").String;
const Log = @import("ziglog");
const dynArray = @import("dynarray").dynArray;
const common = @import("../common.zig");

pub const TokenType = enum {
    TokenUnknow,
    TokenModulo,
    TokenLabel,
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
    tokens: dynArray(Token),
    line_no: usize,
    err: ?Log.LogInfo,
    warn: ?Log.LogInfo,
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

    var err: ?Log.LogInfo = null;
    var warn: ?Log.LogInfo = null;

    var curr_token: ?String = null;
    var string_is_start = false;
    var add_space_after_string = true;

    pub fn next(self: *Self) TokensInfo {
        err = null;
        warn = null;

        comptime var d_array = dynArray(Token);
        var token_stack = d_array.init();

        curr_token = null;
        string_is_start = false;
        add_space_after_string = true;

        while (nextChar()) |c| {
            if (c == '\n') {
                if (string_is_start) {
                    genErr("{s}:{} string is start but not end", .{ self.src_file.get(), curr_line });
                }

                curr_line += 1;

                self.addCurrentToken(&token_stack, &curr_token, .TokenUnknow);

                if (token_stack.ptr) |ptr| {
                    _ = ptr;
                    return .{
                        .tokens = token_stack,
                        .line_no = curr_line - 1,
                        .err = err,
                        .warn = warn,
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
                    add_space_after_string = true;
                    self.addCurrentToken(&token_stack, &curr_token, .TokenUnknow);
                },

                '%' => {
                    self.addCurrentToken(&token_stack, &curr_token, .TokenUnknow);
                    self.addNullToken(&token_stack, .TokenModulo);
                },

                ':' => {
                    self.addCurrentToken(&token_stack, &curr_token, .TokenUnknow);
                    self.addNullToken(&token_stack, .TokenColon);
                },

                ',' => {
                    self.addCurrentToken(&token_stack, &curr_token, .TokenUnknow);
                    self.addNullToken(&token_stack, TokenType.TokenComma);
                },

                ';' => {
                    self.addCurrentToken(&token_stack, &curr_token, .TokenUnknow);

                    while (nextChar() != '\n') {} else {
                        curr_line += 1;
                    }

                    if (token_stack.ptr) |ptr| {
                        _ = ptr;
                        return .{
                            .tokens = token_stack,
                            .line_no = curr_line - 1,
                            .err = err,
                            .warn = warn,
                        };
                    }
                },

                '"' => {
                    string_is_start = !string_is_start;

                    if (string_is_start) {
                        if (curr_token) |ct| {
                            if (ct.buffer) |_| {
                                genErr("{s}:{} string is directly start after other token", .{ self.src_file.get(), curr_line });
                            }
                        }
                    } else {
                        if (curr_token) |ct| {
                            if (ct.buffer) |_| {} else {
                                genWarn("{s}:{} empty string is not recognized", .{ self.src_file.get(), curr_line });
                            }
                        }
                        self.addCurrentToken(&token_stack, &curr_token, .TokenString);
                        add_space_after_string = false;
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
            self.addCurrentToken(&token_stack, &curr_token, .TokenUnknow);

            if (token_stack.ptr) |ptr| {
                _ = ptr;
                return .{
                    .tokens = token_stack,
                    .line_no = curr_line,
                    .err = err,
                    .warn = warn,
                };
            }
        }

        var tmp_array = dynArray(Token).init();

        return .{
            .tokens = tmp_array,
            .line_no = curr_line,
            .err = err,
            .warn = warn,
        };
    }

    fn addCurrentToken(self: *Self, token_stack: *dynArray(Token), current_token: *?String, token_type: TokenType) void {
        if (current_token.*) |ct| {
            if (ct.buffer) |buf| {
                if (!add_space_after_string) {
                    genErr("{s}:{} string is directly end before other token", .{ self.src_file.get(), curr_line });
                }
                var t = if (buf[0] == '$') .TokenLabel else token_type;
                var to = Token{
                    .token_value = ct,
                    .token_type = t,
                };
                token_stack.push(to);
                current_token.* = String.init();
            }
        }
    }

    fn addNullToken(_: Self, token_stack: *dynArray(Token), token_type: TokenType) void {
        add_space_after_string = true;
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

    fn genErr(comptime fmt: []const u8, args: anytype) void {
        var err_log = Log.Log.init();
        var l = err_log.makeLog(fmt, args, .Err);
        err = if (err) |_| err else l;
    }

    fn genWarn(comptime fmt: []const u8, args: anytype) void {
        var warn_log = Log.Log.init();
        var l = warn_log.makeLog(fmt, args, .Warn);
        warn = if (warn) |_| err else l;
    }

    fn printErrorAndExit(comptime fmt: []const u8, args: anytype) void {
        var err_log = Log.Log.init();
        err_log.addLog(fmt, args, .Err);
        err_log.print();
        common.errExit();
    }
};
