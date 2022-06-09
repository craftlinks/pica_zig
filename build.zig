const std = @import("std");
const w32 = @import("libs/zwin32/build.zig");

pub const pkg = std.build.Pkg {
    .name = "zica",
    .source = .{ .path = thisDir() ++ "/src/lib.zig" },
    .dependencies = &[_]std.build.Pkg { w32.pkg, },
};

pub fn build(b: *std.build.Builder) void {
    const build_mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});

    // -- pica lib can also be compiled into a static library --
    // const lib = b.addStaticLibrary("libpica", thisDir() ++ "/src/lib.zig");
    // lib.setBuildMode(build_mode);
    // lib.setTarget(target);
    // lib.install();
    
   
    // An example window application using the pica zig library
    const example_exe = b.addExecutable("example", thisDir() ++ "/src/example.zig");
    example_exe.setBuildMode(build_mode);
    example_exe.setTarget(target);
    example_exe.addPackage(pkg);
    example_exe.install();

    const example_run_cmd = example_exe.run();
    example_run_cmd.step.dependOn(b.getInstallStep());
    const example_run_step = b.step("run", "Run the pica window example");
    example_run_step.dependOn(&example_run_cmd.step);
}

fn thisDir() []const u8 {
    return std.fs.path.dirname(@src().file) orelse ".";
}
