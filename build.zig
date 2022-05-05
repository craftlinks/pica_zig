const std = @import("std");
const zwin32 = @import("libs/zwin32/build.zig");

pub const pkg = std.build.Pkg {
    .name = "pica_zig",
    .path = .{ .path = thisDir() ++ "/src/pica_zig.zig" },
    .dependencies = 
        std.build.Dependency {
            .pkg = "libs/zwin32",
            .path = .{ .path = thisDir() ++ "/src/libs/zwin32/build.zig" },
        },
};

fn thisDir() []const u8 {
    return std.fs.path.dirname(@src().file) orelse ".";
}
