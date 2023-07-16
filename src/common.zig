/// common function, struct...
const std = @import("std");
const config = @import("./config.zig");

pub fn errExit() void {
    std.os.exit(comptime if (config.dev_mode) 0 else 2);
}
