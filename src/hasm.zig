const std = @import("std");
const String = @import("zigstr").String;
const x86_64 = @import("./x86_64/x86_64.zig");

pub fn main() !void {
    x86_64.print_info();
    try parseArg();
}

fn parseArg() !void {
    var a = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer a.deinit();

    var args = try std.process.argsAlloc(std.heap.page_allocator);
    std.debug.print("{s} {}", .{args, args.len});
}
