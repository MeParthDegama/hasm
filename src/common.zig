/// common function, struct...
const std = @import("std");
const config = @import("./config.zig");

pub fn errExit() void {
    if (comptime config.dev_mode) {
        std.debug.print("dev: exit with 2\n", .{});
    } else {
        std.os.exit(2);
    }
}
