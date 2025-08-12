const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    mod.addCMacro("FT2_BUILD_LIBRARY", "1");

    const lib = b.addLibrary(.{
        .name = "freetype",
        .root_module = mod,
    });

    var c_source_files = try std.ArrayList([]const u8).initCapacity(b.allocator, 40);
    c_source_files.appendSliceAssumeCapacity(&.{
        "src/autofit/autofit.c",
        "src/base/ftbase.c",
        "src/base/ftbdf.c",
        "src/base/ftbdf.c",
        "src/base/ftbitmap.c",
        "src/base/ftcid.c",
        "src/base/ftfstype.c",
        "src/base/ftgasp.c",
        "src/base/ftglyph.c",
        "src/base/ftgxval.c",
        "src/base/ftinit.c",
        "src/base/ftmm.c",
        "src/base/ftotval.c",
        "src/base/ftpatent.c",
        "src/base/ftpfr.c",
        "src/base/ftstroke.c",
        "src/base/ftsynth.c",
        "src/base/fttype1.c",
        "src/base/ftwinfnt.c",
        "src/bdf/bdf.c",
        "src/bzip2/ftbzip2.c",
        "src/cache/ftcache.c",
        "src/cff/cff.c",
        "src/cid/type1cid.c",
        "src/gzip/ftgzip.c",
        "src/lzw/ftlzw.c",
        "src/pcf/pcf.c",
        "src/pfr/pfr.c",
        "src/psaux/psaux.c",
        "src/pshinter/pshinter.c",
        "src/psnames/psnames.c",
        "src/raster/raster.c",
        "src/sdf/sdf.c",
        "src/sfnt/sfnt.c",
        "src/smooth/smooth.c",
        "src/svg/svg.c",
        "src/truetype/truetype.c",
        "src/type1/type1.c",
        "src/type42/type42.c",
        "src/winfonts/winfnt.c",
    });

    switch (builtin.target.os.tag) {
        .windows => {
            try c_source_files.append("builds/windows/ftsystem.c");
            try c_source_files.append("builds/windows/ftdebug.c");
        },
        .macos => {
            try c_source_files.append("builds/mac/ftmac.c");
            try c_source_files.append("src/base/ftdebug.c");
        },
        .linux => {
            mod.addCMacro("HAVE_UNISTD_H", "1");
            mod.addCMacro("HAVE_FCNTL_H", "1");
            try c_source_files.append("builds/unix/ftsystem.c");
            try c_source_files.append("src/base/ftdebug.c");
        },
        else => {
            std.log.err("unknow os\n", .{});
        },
    }

    lib.addCSourceFiles(.{
        .files = c_source_files.items,
        .flags = &.{
            "-Wall",
            "-Wundef",
            "-Wfloat-conversion",
            "-fno-strict-aliasing",
            "-Wshadow",
            "-Wno-unused-local-typedefs",
            "-Wimplicit-fallthrough",
        },
    });
    lib.addIncludePath(b.path("include/"));
    lib.installHeadersDirectory(b.path("include/"), "freetype/", .{});
    b.installArtifact(lib);
}
