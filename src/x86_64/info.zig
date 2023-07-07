/// print x86_64 / amd64 info
const std = @import("std");

pub fn print_info() void {
    const info = (
        \\x86_64 / amd64 Manuals
        \\intel x86: https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html
        \\AMD amd64: https://www.amd.com/en/support/tech-docs?keyword=AMD64+Architecture+Programmer%27s+Manual
    );

    std.debug.print("{s}\n", .{info});
}
