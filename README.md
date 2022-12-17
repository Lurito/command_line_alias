# 命令行别名

一个用于创建命令行别的工具，如同 Bash 中 alias 命令，但使用 .exe 实现。

## 使用

使用 zig cc 命令行别名：

1. 先将 `command_line_alias.exe` 重命名为 `zigcc.exe`
2. 将再 `command_line_alias.exe.cfg` 重命名为 `zigcc.exe.cfg`。`zigcc.exe.cfg` 要和 `zigcc.exe` 保持在同一目录。
3. 修改 `zigcc.exe.cfg` 的内容为 `zig cc`
4. 完成。这样就可以通过调用 `zigcc` 命令来使用 `zig cc`

## LICENSE

MIT
