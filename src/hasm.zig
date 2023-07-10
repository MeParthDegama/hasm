const std = @import("std");
const String = @import("zigstr").String;
const x86_64 = @import("./x86_64/x86_64.zig");

pub fn main() !void {
    var args = try getArgs();

    if (args.len < 2) {
        std.debug.print("input file error...\n", .{});
        return;
    }

    var arg1 = args[1];

    if (arg1.equString("info")) {
        x86_64.print_info();
    } else {
        std.debug.print("TODO...\n", .{});
    }
}

fn getArgs() ![]String {
    var args = try std.process.argsAlloc(std.heap.page_allocator);

    var stringA = std.heap.ArenaAllocator.init(std.heap.page_allocator);

    var stringAllocater = stringA.allocator();

    var stringSpace = stringAllocater.alloc(String, args.len) catch unreachable;

    for (args, 0..) |arg, i| {
        stringSpace[i] = String.initString(arg);
    }

    return stringSpace;
}
