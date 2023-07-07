const std = @import("std");
const x86_64 = @import("./x86_64/x86_64.zig");

pub fn main() !void {
    
    x86_64.print_info();

}
