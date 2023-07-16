const std = @import("std");
const String = @import("zigstr").String;
const Log = @import("ziglog").Log;

const x86_64 = @import("./x86_64/x86_64.zig").x86_64;

pub fn main() !void {
    var args = try getArgs();

    if (args.len < 2) {
        var l = Log.init();
        l.err("input file error...", .{});
        l.print();
        std.os.exit(2);
    }

    var arg1 = args[1];

    if (arg1.equString("info")) {
        x86_64.printInfo();
    } else {
        var x86_64_bin = x86_64.init();
        defer x86_64_bin.deinit();

        x86_64_bin.setRootSrcFile(arg1);
        try x86_64_bin.assemble();
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
