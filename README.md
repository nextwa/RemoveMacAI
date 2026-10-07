# RemoveMacAI 中文版

[下载 DMG](https://github.com/nextwa/RemoveMacAI/releases/latest) · [详细中文指南](README.zh-Hans.md) · [上游项目](https://github.com/omlahore/RemoveMacAI)

基于 RemoveMacAI v1.0.1 的简体中文版本。精简 macOS 的 Apple 智能、隐私、访达、程序坞及输入设置，查看后台项目和可清理空间，并支持撤销设置更改。

## 安装

1. 在 [Releases](https://github.com/nextwa/RemoveMacAI/releases/latest) 下载 `RemoveMacAI-1.0.1-zh-Hans.1-arm64.dmg`。
2. 打开 DMG，将 **RemoveMacAI 中文版** 拖到 **Applications（应用程序）**。
3. 从“应用程序”启动。首次打开若被 macOS 拦截，前往 **系统设置 → 隐私与安全性 → 仍要打开**。

适用 Apple 芯片 Mac；已在 macOS 27.0.1 上验证。可与英文版并存，共用原有设置记录和配置描述文件。

## 汉化范围

- 11 个页面，40 项系统调整的名称、解释和注意事项。
- 14 项 AI 功能，5 类模型名称，2 种预设。
- 操作预览、描述文件授权引导、执行结果与错误提示。
- 命令行帮助和输出；技术标识、参数及 JSON 字段保持原格式。
- [详细指南](README.zh-Hans.md)：中英文对照、功能说明、清理行为、恢复方法及命令行示例。

系统调整在“检查并应用”后执行；后台项目开关立即生效。普通清理文件移入废纸篓，模拟器和时间机器本地快照会永久删除。

## 验证

发布应用编译、签名验证及 70 项上游自测通过。正式应用已在 Apple 芯片、macOS 27.0.1 上启动并检查中文界面。预览与实际执行使用相同的撤销选择。

## 构建

```sh
bash tools/build-app.sh
.build/release/removemacai selftest
python3 -m venv .build/dmg-venv
.build/dmg-venv/bin/pip install -r tools/dmg-requirements.txt
.build/dmg-venv/bin/python tools/build-dmg.py
```

构建工具读取 `SDKROOT`，未设置时使用当前开发工具的 SDK。应用输出到 `.build/RemoveMacAI 中文版.app`，DMG 输出到 `dist/`。发布所用环境及 SDK 指定方法见[中文指南](README.zh-Hans.md#源码与构建)。

## 已知限制

本版本使用本地签名，未经过 Apple 公证。macOS 自带窗口、第三方名称及系统原始错误可能保留英文。验证不包含实际删除用户文件或模型；上游新版本需单独合并汉化。此版本未提供自动更新。

## 来源与许可证

原作者：[Om Lahore](https://github.com/omlahore)。Apple 智能移除功能基于 [4evy/pared](https://github.com/4evy/pared)。本项目为独立维护的中文 fork，保留 [MIT 许可证](LICENSE)和[第三方声明](THIRD-PARTY-NOTICES.md)。[上游说明](README.upstream.md)。
