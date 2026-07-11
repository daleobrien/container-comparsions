const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    try std.Io.File.stdout().writeStreamingAll(io, "Hello, world!\n");
}
