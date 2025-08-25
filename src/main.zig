const std = @import("std");

fn log(comptime fmt: []const u8, args: anytype) void {
    std.log.debug(fmt, args);
}

var allocator: std.mem.Allocator = std.heap.page_allocator;

fn getAliasConfigFilePath(bin_path: []const u8) ![]const u8 {
    const dir = try std.fs.selfExeDirPathAlloc(allocator);
    defer allocator.free(dir);

    const bin_name = std.fs.path.basename(bin_path);
    const config_file_name = try std.fmt.allocPrint(allocator, "{s}.cfg", .{bin_name});
    defer allocator.free(config_file_name);

    const config_file = try std.fs.path.join(allocator, &[_][]const u8{ dir, config_file_name });
    return config_file;
}

fn getAliasConfig(config_file: []const u8) ![][]const u8 {
    var file = std.fs.openFileAbsolute(config_file, .{}) catch |err| {
        switch (err) {
            error.FileNotFound => {
                std.log.err("config file '{s}' not found", .{config_file});
            },
            else => {
                std.log.err("unknown error, {s}", .{@errorName(err)});
            },
        }
        std.process.exit(1);
    };
    defer file.close();

    const content = try file.readToEndAlloc(allocator, std.math.maxInt(u32));
    defer allocator.free(content);

    const content_ = try std.mem.replaceOwned(u8, allocator, content, "\r\n", "");
    defer allocator.free(content_);

    var iter = std.mem.splitSequence(u8, content_, " ");
    var buf = std.ArrayList([]const u8).init(allocator);
    defer buf.deinit();

    while (iter.next()) |text| {
        if (text.len == 0) {
            continue;
        }

        const copied = try allocator.dupe(u8, text);
        errdefer allocator.free(copied);

        try buf.append(copied);
    }

    return buf.toOwnedSlice();
}

fn getCommandLine(args: [][:0]u8) ![][]const u8 {
    var command_line = std.ArrayList([]const u8).init(allocator);
    defer command_line.deinit();

    const bin_name = args[0];
    const config_file = try getAliasConfigFilePath(bin_name);
    defer allocator.free(config_file);

    const alias_conf = try getAliasConfig(config_file);
    defer allocator.free(alias_conf);

    log("alias config: {any}", .{alias_conf});

    // 拼接实际的命令行
    try command_line.appendSlice(alias_conf);

    const flags = args[1..];
    log("appended flags: {any}", .{flags});

    // 拼接其他命令行参数
    if (flags.len > 0) {
        try command_line.appendSlice(flags);
    }

    return command_line.toOwnedSlice();
}

const log_level: std.log.Level = .info;

pub fn main() !void {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const command_line = try getCommandLine(args);
    defer allocator.free(command_line);

    log("command_line: {any}", .{command_line});

    var child = std.process.Child.init(command_line, allocator);
    child.stdin_behavior = .Inherit;
    child.stdout_behavior = .Inherit;
    child.stderr_behavior = .Inherit;

    const term = try child.spawnAndWait();

    const exit_code: u8 = @intCast(switch (term) {
        .Exited => |n| n,
        .Signal => |n| n,
        .Stopped => |n| n,
        .Unknown => |n| n,
    });

    std.process.exit(exit_code);
}
