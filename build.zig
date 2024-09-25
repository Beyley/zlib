const std = @import("std");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});
    const shared = b.option(bool, "zlib-shared", "Whether to build zlib as a shared library") orelse false;

    const srcs = &.{
        "adler32.c",
        "compress.c",
        "crc32.c",
        "deflate.c",
        "gzclose.c",
        "gzlib.c",
        "gzread.c",
        "gzwrite.c",
        "inflate.c",
        "infback.c",
        "inftrees.c",
        "inffast.c",
        "trees.c",
        "uncompr.c",
        "zutil.c",
    };

    const options = .{
        .name = "z",
        .target = target,
        .optimize = optimize,
    };

    const zlib = if (shared)
        b.addSharedLibrary(options)
    else
        b.addStaticLibrary(options);

    zlib.linkLibC();

    zlib.defineCMacro("_LARGEFILE64_SOURCE", "1");

    if (target.result.abi == .msvc) {
        zlib.defineCMacro("_CRT_SECURE_NO_DEPRECATE", "1");
        zlib.defineCMacro("_CRT_NONSTDC_NO_DEPRECATE", "1");
    }

    zlib.addCSourceFiles(.{
        .files = srcs,
        .flags = &.{},
    });

    zlib.installHeader(b.path("zlib.h"), "zlib.h");
    zlib.installHeader(b.path("zconf.h"), "zconf.h");

    b.installArtifact(zlib);
}
