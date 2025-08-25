# 命令行别名

一个用于创建命令行别名的小工具。如同 Bash 的 alias 命令，但使用 .exe 实现。

## 构建方式

当前版本基于 Zig v0.14.x API 开发。由于 Zig 未进入 stable 且 API 变化极快，更高版本可能无法构建。

``` bash
zig build --release=fast
```

## 使用示例

使用 zig cc 命令行别名：

1. 先将 `command_line_alias.exe` 重命名为 `zigcc.exe`
2. 将再 `command_line_alias.exe.cfg` 重命名为 `zigcc.exe.cfg`。`zigcc.exe.cfg` 要和 `zigcc.exe` 保持在同一目录。
3. 修改 `zigcc.exe.cfg` 的内容为 `zig cc`
4. 这样就可以通过调用 `zigcc` 命令来使用 `zig cc`

## LICENSE

MIT
