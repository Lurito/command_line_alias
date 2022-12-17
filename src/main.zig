const std = @import("std");

fn log(comptime fmt: []const u8, args: anytype) void {
    std.log.debug(fmt, args);
}

var allocator: std.mem.Allocator = std.heap.page_allocator;

fn getAliasConfig(bin_path: []const u8) ![][]const u8 {
    var dir = try std.fs.selfExeDirPathAlloc(allocator);
    defer allocator.free(dir);

    var bin_name = std.fs.path.basename(bin_path);
    var config_file_name = try std.fmt.allocPrint(allocator, "{s}.cfg", .{bin_name});
    defer allocator.free(config_file_name);

    var config_file = try std.fs.path.join(allocator, &[_][]const u8{ dir, config_file_name });
    defer allocator.free(config_file);

    var file = try std.fs.openFileAbsolute(config_file, .{});
    defer file.close();

    var content = try file.readToEndAlloc(allocator, std.math.maxInt(u32));
    defer allocator.free(content);

    var iter = std.mem.split(u8, content, " ");
    var buf = std.ArrayList([]const u8).init(allocator);
    defer buf.deinit();

    while (iter.next()) |text| {
        if (text.len == 0) {
            continue;
        }

        const copied = try allocator.dupe(u8, text);
        try buf.append(copied);
    }

    return buf.toOwnedSlice();
}

fn getCommandLine(args: [][]const u8) ![][]const u8 {
    var command_line = std.ArrayList([]const u8).init(allocator);
    defer command_line.deinit();

    var bin_name = args[0];
    var alias_conf = try getAliasConfig(bin_name);
    defer allocator.free(alias_conf);

    log("alias config: {any}", .{alias_conf});

    // 拼接实际的命令行
    try command_line.appendSlice(alias_conf);

    var flags = args[1..];
    log("appended flags: {any}", .{flags});

    // 拼接其他命令行参数
    if (flags.len > 0) {
        try command_line.appendSlice(flags);
    }

    return command_line.toOwnedSlice();
}

pub const log_level: std.log.Level = .info;

pub fn main() !void {
    var args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const command_line = try getCommandLine(args);
    defer allocator.free(command_line);

    log("command_line: {any}", .{command_line});

    var proc = std.ChildProcess.init(command_line, allocator);
    var res = try proc.spawnAndWait();
    std.process.exit(res.Exited);
}

test "combine command_line" {
    allocator = std.testing.allocator;

    var args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const command_line = try getCommandLine(args);
    defer allocator.free(command_line);

    log("command_line: {any}", .{command_line});
}
