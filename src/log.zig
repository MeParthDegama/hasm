/// print log
const std = @import("std");

pub const Log = struct {
    const Self = @This();

    const LogType = enum {
        Err,
        Warn,
    };

    const LogInfo = struct {
        buf: []u8,
        log_type: LogType,
    };

    var log_stack: ?[]LogInfo = null;

    var allocater: std.heap.ArenaAllocator = undefined;
    var a: std.mem.Allocator = undefined;

    pub fn init() Self {
        allocater = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        a = allocater.allocator();

        return Self{};
    }

    pub fn deinit() void {
        allocater.deinit();
    }

    fn addLog(comptime fmt: []const u8, args: anytype, log_type: LogType) void {
        var log_buf = logFmt(fmt, args);

        var l = LogInfo{
            .buf = log_buf,
            .log_type = log_type,
        };

        if (log_stack) |log_s| {
            var stack_ptr = a.realloc(log_s, log_s.len + 1) catch {
                std.debug.print("error: log info allocation error...", .{});
                std.os.exit(2);
            };
            log_stack = stack_ptr;
            log_stack.?[log_s.len] = l;
        } else {
            var stack_ptr = a.alloc(LogInfo, 1) catch {
                std.debug.print("error: log info allocation error...", .{});
                std.os.exit(2);
            };
            log_stack = stack_ptr;
            log_stack.?[0] = l;
        }
    }

    pub fn err(_: *Self, comptime fmt: []const u8, args: anytype) void {
        addLog(fmt, args, LogType.Err);
    }

    pub fn warn(_: *Self, comptime fmt: []const u8, args: anytype) void {
        addLog(fmt, args, LogType.Warn);
    }

    pub fn print(_: Self) void {
        if (log_stack) |log_s| {
            for (log_s) |v| {
                printLog(v);
            }
        }
    }

    pub fn len(_: Self) usize {
        if (log_stack) |log_s| {
            return log_s.len;
        }

        return 0;
    }

    fn printLog(log: LogInfo) void {
        switch (log.log_type) {
            LogType.Err => {
                std.debug.print("\x1b[31merror:\x1b[39m {s}\n", .{log.buf});
            },
            LogType.Warn => {
                std.debug.print("\x1b[33mwarning:\x1b[39m {s}\n", .{log.buf});
            },
        }
    }

    fn logFmt(comptime fmt: []const u8, args: anytype) []u8 {
        var buff = a.alloc(u8, 1024) catch {
            std.debug.print("error: allocation error...", .{});
            std.os.exit(2);
        };

        var aBuff = std.fmt.bufPrint(buff, fmt, args) catch {
            std.debug.print("error: fmt error...", .{});
            std.os.exit(2);
        };

        return aBuff;
    }

    pub fn printWarn(comptime fmt: []const u8, args: anytype) void {
        var fmt_buf = logFmt(fmt, args);
        printLog(.{
            .buf = fmt_buf,
            .log_type = LogType.Warn,
        });
    }

    pub fn printErr(comptime fmt: []const u8, args: anytype) void {
        var fmt_buf = logFmt(fmt, args);
        printLog(.{
            .buf = fmt_buf,
            .log_type = LogType.Err,
        });
    }
};
