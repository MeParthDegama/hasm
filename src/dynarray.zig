/// dyn array
const std = @import("std");

pub fn initArray(comptime t: type) type {
    return struct {
        ptr: ?[]t,

        const Self = @This();

        var a: std.heap.ArenaAllocator = undefined;
        var allocater: std.mem.Allocator = undefined;

        pub fn init() Self {
            a = std.heap.ArenaAllocator.init(std.heap.page_allocator);
            allocater = a.allocator();

            return Self{
                .ptr = null,
            };
        }

        pub fn push(self: *Self, m: t) void {
            if (self.ptr) |ptr| {
                self.ptr = allocater.realloc(ptr, ptr.len + 1) catch unreachable;
                self.ptr.?[self.ptr.?.len - 1] = m;
            } else {
                self.ptr = allocater.alloc(t, 1) catch unreachable;
                self.ptr.?[0] = m;
            }
        }

        pub fn deinit(_: Self) void {
            a.deinit();
        }

    };
}
