# 命令行别名 Command-line Alias

一个用于创建命令行别名的小工具。如同 Bash 的 alias 命令，但使用可执行程序实现。

A command-line alias tool, like Bash alias, but implemented by executable program.

## 构建方式 Build

当前版本基于 Zig v0.15.x API 开发。由于 Zig 未进入 stable 且 API 变化极快，更高版本可能无法构建。

``` bash
zig build --release=fast
```

## 使用示例 Usage

以使用 `zig cc` 命令行别名为例：

Take the `zig cc` command-line alias as an example:

1. 先将 `command_line_alias.exe` 重命名为 `zigcc.exe`。

   Rename `command_line_alias.exe` to `zigcc.exe`.

2. 在同一目录创建文本文件 `zigcc.exe.cfg`。

   Create a text file `zigcc.exe.cfg` in the same directory.

3. 修改 `zigcc.exe.cfg` 的内容为 `zig cc`。

   Edit `zigcc.exe.cfg` to contain `zig cc`.

4. 这样就可以通过调用 `zigcc` 命令来使用 `zig cc`。

   Then you can use the `zigcc` command to invoke `zig cc`.

## 开源许可证 Open-source License

[MIT](./LICENSE)
