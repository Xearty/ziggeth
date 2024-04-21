const std = @import("std");
const Allocator = std.mem.Allocator;

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    try compileContracts(allocator);

    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "evm",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const math_module = b.createModule(.{
        .root_source_file = .{ .path = "src/math/root.zig" },
    });

    const common_dst_module = b.createModule(.{
        .root_source_file = .{ .path = "src/common_dst/root.zig" },
    });

    const eth_types_module = b.createModule(.{
        .root_source_file = .{ .path = "src/eth_types/root.zig" },
    });

    const execution_engine_module = b.createModule(.{
        .root_source_file = .{ .path = "src/execution_engine/root.zig" },
    });

    const utils_module = b.createModule(.{
        .root_source_file = .{ .path = "src/utils/root.zig" },
    });

    exe.root_module.addImport("utils", utils_module);
    exe.root_module.addImport("eth_types", eth_types_module);
    exe.root_module.addImport("execution_engine", execution_engine_module);

    execution_engine_module.addImport("utils", utils_module);
    execution_engine_module.addImport("eth_types", eth_types_module);
    execution_engine_module.addImport("math", math_module);
    execution_engine_module.addImport("common_dst", common_dst_module);

    utils_module.addImport("eth_types", eth_types_module); // TODO: get rid of this dependency

    common_dst_module.addImport("utils", utils_module);

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const evm_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/tests/evm_tests.zig" },
        .target = target,
        .optimize = optimize,
    });
    // evm_tests.root_module.addImport("evm", evm_module);
    // evm_tests.root_module.addImport("types", types_module);

    const run_lib_unit_tests = b.addRunArtifact(evm_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}

fn compileContracts(allocator: Allocator) !void {
    const solidity_dir = "./src/execution_engine/solidity/";
    const out_dir = try std.mem.concat(allocator, u8, &.{ solidity_dir, "out" });

    var cwd = try std.fs.cwd().openDir(solidity_dir, .{ .iterate = true });
    defer cwd.close();

    var cwd_iter = cwd.iterate();
    while (try cwd_iter.next()) |entry| {
        if (entry.kind == .file) {
            const path = try std.mem.concat(allocator, u8, &.{ solidity_dir, entry.name });
            const result = try std.ChildProcess.run(.{
                .allocator = allocator,
                .argv = &[_][]const u8{ "solc", path, "--bin", "-o", out_dir, "--overwrite" },
            });

            switch (result.term) {
                .Exited => |exit_code| {
                    if (exit_code == 0) {
                        std.log.info("Compiled {s} successfully\n", .{path});
                    } else {
                        std.log.err("{s}\n", .{result.stdout});
                        std.process.exit(1);
                    }
                },
                else => unreachable,
            }
        }
    }
}
