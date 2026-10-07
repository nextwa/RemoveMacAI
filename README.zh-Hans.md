# RemoveMacAI 中文版使用指南

基于 [omlahore/RemoveMacAI](https://github.com/omlahore/RemoveMacAI) 的 **v1.0.1** 制作，适用于 Apple 芯片 Mac。已在 macOS 27.0.1 上验证。此版本提供简体中文界面、功能解释、确认流程及命令行帮助。

## 安装与使用

1. 从本仓库 Releases 下载 DMG，打开后将 **RemoveMacAI 中文版** 拖入 **Applications（应用程序）**，然后从“应用程序”或聚焦搜索启动。
2. 从“概览”查看当前状态，或从左侧进入需要调整的页面。
3. 修改 Apple 智能或系统调整的开关后，点击底部“检查并应用…”，逐项确认，再点击“应用”。
4. 对于带锁的设置，按中文提示前往“系统设置 > 通用 > 设备管理”，双击 RemoveMacAI 描述文件并安装，输入本机管理员密码。
5. 等待应用显示结果；如提示仍有模型残留，可稍后重新载入查看。

中文版采用独立的应用名称和标识，可以与英文版并存。两个版本共用设置记录和 RemoveMacAI 描述文件，原版执行的调整可在中文版查看和撤销。使用时打开其中一个版本即可。

中文版直接显示中文，无需修改整个 macOS 的系统语言。上游英文版的更新不会同步合并到这个中文版本；安装新的上游版本后，应重新为对应版本合并汉化。

## 页面与开关的含义

| 原版名称 | 中文名称 | 用途 |
| --- | --- | --- |
| Overview | 概览 | 查看 AI 状态、系统调整数量、后台项目和可清理空间，选择预设。 |
| Apple Intelligence | Apple 智能 | 关闭 Apple 的系统 AI 功能，选择保留功能，检查和移除相关模型。 |
| Privacy | 隐私 | 调整分析共享、个性化广告、搜索建议及 Game Center。 |
| Annoyances | 减少干扰 | 处理点按壁纸、桌面小组件、播放键和 iPhone 镜像。 |
| Apple Apps | Apple 应用 | 关闭部分应用服务，移除程序坞图标。 |
| Finder | 访达 | 调整文件显示、搜索、保存和资源库可见性。 |
| Dock and Windows | 程序坞与窗口 | 调整程序坞、动画、平铺窗口及截图阴影。 |
| Typing | 键盘输入 | 调整自动纠正、标点替换、大写及长按按键。 |
| Background Items | 后台项目 | 查看并启停第三方后台更新或辅助程序。 |
| Storage | 储存空间 | 扫描并清理指定文件、模拟器和本地快照。 |
| Undo | 撤销更改 | 查看描述文件及历史记录，恢复之前的设置。 |

**系统调整页面中，开关开启表示“应用该行描述的调整”。** 例如“关闭个性化广告”的开关打开，表示将关闭个性化广告。开关标题中的动作决定实际含义。

**Apple 智能页面有两层选择。** 顶部“关闭 Apple 智能”决定是否执行关闭；下方“保留以下功能”的开关打开，表示保留该功能及其需要的模型。下方的“已开启／已关闭”文字是当前系统状态，尚未应用的选择不会立刻改变这行状态。

**后台项目页面直接生效。** 这里的开关表示后台项目本身是否开启，切换后立即执行，不进入底部的“检查并应用”流程。

**“删除剩余模型”会直接发起删除请求。** 它只在 Apple 智能已经关闭、仍检测到模型文件时出现，不会再弹出普通调整的预览窗口。

## 两种预设

- **推荐方案（recommended）**：关闭 Apple 智能、Mac 分析、个性化广告、改进 Siri 与听写、改进搜索、聚焦搜索互联网结果和查询建议；停止点按壁纸显示桌面、停止播放键启动音乐；显示文件扩展名和路径栏、文件夹优先、禁止网络磁盘 .DS_Store、隐藏程序坞最近应用。
- **更强隐私（privacy）**：包含推荐方案，再关闭 Safari 搜索建议和 Game Center。

预设会在已有调整上增加选项，保留当前已选的 AI 保留项。选择预设会打开预览，点击“应用”后才执行。选择前应留意：Game Center 可能关系到游戏存档和联机，Safari 搜索建议关闭后不会边输入边提示搜索词。

## Apple 智能功能逐项解释

“ChatGPT 与其他 AI 扩展集成”指 Apple 系统内的外部 AI 集成入口。此项目不卸载独立的 ChatGPT、Codex、浏览器或第三方本地模型应用，也不清理它们下载的模型目录。

| 原版名称 | 中文名称 | 说明 | 命令行标识 |
| --- | --- | --- | --- |
| Siri and Siri AI | Siri 与智能 Siri | 控制 Siri 助理及相关智能功能。 | `siri` |
| ChatGPT and other AI extensions | ChatGPT 与其他 AI 扩展集成 | 控制 Apple 系统中的 ChatGPT 和其他外部 AI 扩展集成，包括集成登录。 | `chatgpt` |
| Writing Tools | 写作工具 | 用于改写、校对与整理文本的写作工具。 | `writing-tools` |
| Genmoji | 智绘表情（Genmoji） | 根据描述生成自定义表情，使用基础模型及图像模型。 | `genmoji` |
| Image Playground | 图乐园（Image Playground） | 根据描述或素材生成图像，使用基础模型及图像模型。 | `image-playground` |
| Mail summaries and smart replies | 邮件摘要与智能回复 | 邮件内容摘要和智能回复建议。 | `mail` |
| Notification summaries | 通知摘要 | 将较长或多条通知汇总成摘要。 | `notification-summaries` |
| Messages summaries | 信息摘要 | 对“信息”中的内容生成摘要。 | `messages-summaries` |
| Safari summaries | Safari 网页摘要 | 对 Safari 网页内容生成摘要。 | `safari-summaries` |
| Notes transcription summaries | 备忘录转写摘要 | 对备忘录中的转写内容生成摘要。 | `notes-summaries` |
| Inline text predictions | 行内文本预测 | 在输入位置提供行内文本补全预测，不等同于听写。 | `inline-predictions` |
| Spatial Photos | 空间照片 | 照片的空间效果功能，使用独立的空间照片模型。 | `spatial-photos` |
| Photos Clean Up | 照片清理 | “照片”编辑器中的清理功能，使用独立模型；在照片编辑界面中使用。 | `photos-clean-up` |
| Xcode predictive code completion | Xcode 预测式代码补全 | Xcode 的预测式代码补全，使用代码模型。 | `xcode-completion` |

多个功能可能共用同一模型，保留其中一个功能就可能需要保留整组模型。模型不是按开关数量等比例占用磁盘。5 类模型分别是基础模型、图像与智绘表情模型、空间照片模型、照片清理模型、Xcode 代码补全模型。

## 40 项系统调整的详细翻译

下表中的标识保持上游英文写法，可用于命令行。说明和注意事项对应中文版界面。

### 隐私

| 英文原名／标识 | 中文选项 | 详细说明 |
| --- | --- | --- |
| Turn off Mac Analytics<br>`analytics` | 关闭 Mac 分析 | 停止向 Apple 及应用开发者发送诊断和使用情况数据。 |
| Turn off personalized ads<br>`personalized-ads` | 关闭个性化广告 | 阻止 Apple 根据你的应用使用行为，在 App Store、新闻及股市中投放个性化广告。 |
| Turn off Improve Siri and Dictation<br>`improve-siri` | 关闭“改进 Siri 与听写” | 停止允许 Apple 储存和评估你的 Siri 请求与听写录音。 |
| Turn off Improve Search<br>`improve-search` | 关闭“改进搜索” | 停止允许 Apple 保留你的聚焦搜索、Safari 和查询内容来改进搜索服务。 |
| Turn off Spotlight internet results<br>`spotlight-web` | 关闭聚焦搜索的互联网结果 | 让聚焦搜索保留在本机，不再向 Apple 发送搜索内容以获取网络建议。 |
| Turn off Look Up suggestions<br>`lookup-suggestions` | 关闭“查询”建议 | 阻止“查询”功能将你选中的词语发送给 Apple 以获取网络结果。 |
| Turn off Safari search suggestions<br>`safari-suggestions` | 关闭 Safari 搜索建议 | 阻止 Safari 为提供建议，将地址栏中尚在输入的内容发送给搜索引擎和 Apple。 **注意：输入时，地址栏将不再提供搜索建议。** |
| Turn off Game Center<br>`game-center` | 关闭 Game Center（游戏中心） | 关闭 Game Center，同时关闭其登录提示、好友请求及通知。 **注意：依赖 Game Center 的游戏将无法使用其进度保存或在线游戏功能。** |

### 减少干扰

| 英文原名／标识 | 中文选项 | 详细说明 |
| --- | --- | --- |
| Stop clicks on the wallpaper hiding windows<br>`click-to-desktop` | 关闭“点按壁纸显示桌面” | 避免误点桌面壁纸时，所有窗口移开以显示桌面。 |
| Hide desktop widgets<br>`desktop-widgets` | 隐藏桌面小组件 | 隐藏桌面小组件，包括台前调度模式下的小组件。 |
| Stop the play key opening Music<br>`media-keys` | 阻止播放键打开“音乐” | 没有其他内容播放时，按播放键不再自动启动“音乐”应用。 **注意：之后不能再用播放键直接启动“音乐”。** |
| Turn off iPhone Mirroring<br>`iphone-mirroring` | 关闭 iPhone 镜像 | 禁用 iPhone 镜像，隐藏相关应用入口及提示。 |

### Apple 应用

| 英文原名／标识 | 中文选项 | 详细说明 |
| --- | --- | --- |
| Turn off Apple Music in the Music app<br>`music-classic` | 关闭“音乐”中的 Apple Music 服务 | 让“音乐”主要用于播放自己的资料库，移除商店和订阅提示。 **注意：Apple Music 订阅用户将无法使用流媒体播放。** |
| Turn off the Book Store<br>`book-store` | 关闭图书商店 | 隐藏“图书”应用中的商店，保留你已有的图书。 |
| Remove unused Apple apps from the Dock<br>`dock-apple-apps` | 从程序坞移除部分 Apple 应用 | 从程序坞移除新闻、TV、音乐、播客、图书、无边记、地图和股市的图标。应用本身仍保留安装。 |

### 访达

| 英文原名／标识 | 中文选项 | 详细说明 |
| --- | --- | --- |
| Show file extensions<br>`file-extensions` | 显示文件扩展名 | 显示文件的完整名称及扩展名，方便辨别实际文件类型。 |
| Show hidden files<br>`hidden-files` | 显示隐藏文件 | 显示 macOS 默认隐藏的文件，例如 .gitignore 和 .zshrc。也可按 Command–Shift–句号切换。 |
| Show the path bar<br>`path-bar` | 显示路径栏 | 在访达窗口底部显示当前文件夹的位置。 |
| Show the status bar<br>`status-bar` | 显示状态栏 | 在访达窗口底部显示项目数量及可用空间。 |
| Keep folders above files<br>`folders-first` | 按名称排序时文件夹在前 | 按名称排序时，将文件夹排列在文件之前。 |
| Search the current folder<br>`search-this-folder` | 默认搜索当前文件夹 | 让访达默认搜索当前文件夹，而不是整台 Mac。 |
| Skip the extension change warning<br>`extension-warning` | 关闭修改扩展名的确认提示 | 修改文件扩展名时，访达不再逐次弹出确认提示。 |
| Show the full path in the title bar<br>`path-in-title` | 在标题栏显示完整路径 | 在访达窗口顶部显示当前文件夹的完整路径。 |
| Stop .DS_Store files on network drives<br>`network-ds-store` | 不在网络磁盘写入 .DS_Store | 阻止访达在其他电脑或 NAS 的共享文件夹中写入 .DS_Store 文件。 |
| Empty the Trash after 30 days<br>`trash-30-days` | 自动删除废纸篓中超过 30 天的项目 | 自动彻底删除已在废纸篓中保留 30 天的项目，减少磁盘占用。 |
| Save new documents on this Mac<br>`save-locally` | 默认将新文稿存到本机 | 保存对话框默认选择本机位置，而不是 iCloud 云盘。 |
| Expand Save dialogs<br>`expanded-save` | 默认展开保存对话框 | 打开保存对话框时，直接显示完整的文件夹浏览界面。 |
| Show the Library folder<br>`show-library` | 显示用户资源库文件夹 | 在个人文件夹中显示默认隐藏的资源库（Library）文件夹。 |

### 程序坞与窗口

| 英文原名／标识 | 中文选项 | 详细说明 |
| --- | --- | --- |
| Hide recent apps in the Dock<br>`dock-recents` | 隐藏程序坞中的最近使用应用 | 不再在程序坞中自动显示最近打开的应用。 |
| Remove the Dock auto-hide delay<br>`dock-delay` | 取消程序坞自动隐藏后的显示延迟 | 将指针移至屏幕边缘时立即显示程序坞，无需等待约半秒。 |
| Stop Dock icons bouncing<br>`dock-bounce` | 关闭程序坞图标的启动弹跳 | 启动应用时，程序坞图标不再弹跳。 |
| Minimize windows into their app icon<br>`minimize-to-app` | 将窗口最小化到应用图标 | 将最小化的窗口收进对应应用图标，减少程序坞中的独立窗口缩略图。 |
| Turn off window opening animations<br>`window-animations` | 关闭窗口打开动画 | 直接显示新窗口，跳过缩放动画。 |
| Remove gaps between tiled windows<br>`tile-margins` | 移除平铺窗口之间的间距 | 移除贴靠屏幕边缘平铺时，窗口周围的留白。 |
| Remove shadows from window screenshots<br>`screenshot-shadow` | 移除窗口截图阴影 | 截取单个窗口时，不再保留周围的大面积阴影。 |

### 键盘输入

| 英文原名／标识 | 中文选项 | 详细说明 |
| --- | --- | --- |
| Turn off autocorrect<br>`autocorrect` | 关闭自动纠正拼写 | 停止在输入过程中自动纠正词语拼写。 |
| Turn off smart quotes and dashes<br>`smart-punctuation` | 关闭智能引号和破折号 | 保留直引号和连续两个连字符，不自动替换为弯引号或破折号，适合代码和终端输入。 |
| Turn off period on double space<br>`double-space-period` | 关闭连按两次空格输入句号 | 连续输入两个空格时，不再自动替换为句号。 |
| Turn off automatic capitals<br>`auto-capitalize` | 关闭自动大写 | 停止自动将句首单词的首字母改为大写。 |
| Repeat held keys instead of showing accents<br>`key-repeat` | 长按按键时重复输入 | 长按按键时连续输入该字符，不再弹出重音字符菜单。 **注意：需要输入重音字符时，请改用 Option 快捷键或字符检视器。** |

## 后台项目如何使用

每项会显示程序名称、launchd 标识和实际执行路径。标记“所有用户”的项目属于系统级后台项目，修改时通常需要管理员密码。

- 更新程序：关闭后会影响对应软件的自动更新。
- 辅助程序：可能承担 VPN 连接、Docker 通信、同步或授权等必要功能。界面会显示相应提醒。
- Apple 系统后台服务：此页面不列入批量关闭范围。保持系统完整性保护（SIP）开启。

关闭项目不会卸载对应应用。可重新打开开关，也可通过“撤销全部更改”恢复受记录的项目。

## 储存空间清理逐项说明

| 项目 | 内容及清理后的行为 |
| --- | --- |
| 航拍壁纸视频 | 动态壁纸和屏保素材。再次选择时会下载；当前正在使用的素材可能很快又被下载。 |
| macOS 安装程序 | “应用程序”中的旧“安装 macOS”应用。 |
| iPhone 与 iPad 更新文件 | 访达下载的软件更新包，需要时重新下载。 |
| Xcode 构建数据 | DerivedData 构建缓存，下次构建重新生成。 |
| Xcode 设备支持文件 | 已连接设备的调试符号，再次连接时重新获取。 |
| 不可用的模拟器 | 对应运行环境已不在的模拟器，立即永久删除。 |
| 应用缓存 | 用来加快启动和加载的文件，建议先退出相关应用；清理后首次运行可能变慢。已识别的系统缓存保留。 |
| GarageBand、iMovie、Keynote、Numbers、Pages | 已安装的 Apple 可选应用，可从 App Store 重新安装。GarageBand 音色库若被 Logic Pro 或 MainStage 共用则保留。 |
| 时间机器本地快照 | 保存在本机磁盘上的快照，立即永久删除；外部备份磁盘上的备份保留。 |

点击“扫描”只读取目录和大小。扫描后，程序默认选中检测到的旧安装程序、iOS 更新包、Xcode 构建数据和不可用模拟器；点击清理前请逐项查看。

普通文件移入废纸篓，清倒废纸篓后才释放相应空间。模拟器和本地快照不经过废纸篓。“撤销全部更改”只恢复设置，不会恢复永久删除的数据，也不会自动把废纸篓中的文件放回原处。

## 确认、描述文件和撤销

- **放弃更改**：丢弃尚未应用的选择，并重新读取当前状态。
- **检查并应用**：列出即将应用和撤销的项目，可展开查看系统命令。`defaults`、路径、域名及设置键名保留原文，便于核对。
- **带锁图标**：通过配置描述文件强制应用的设置。macOS 要求用户在“系统设置”中批准。
- **部分应用**：一个调整包含多项设置，目前只有部分符合目标状态。未操作时保持现状。
- **由其他描述文件管理**：该设置被其他配置管理，当前不能通过这个开关修改。
- **撤销全部更改**：恢复记录中的原设置，并引导移除描述文件。原始值记录在 `~/Library/Application Support/RemoveMacAI/journal.json`。

仅删除应用不会自动撤销已经应用的设置。要完整卸载并恢复，应先使用“撤销更改 > 撤销全部更改…”，按提示移除 RemoveMacAI 描述文件，然后再删除应用。

只想回到英文界面时，退出中文版并打开原来的英文版即可，不必执行“撤销全部更改”。

## 命令行用法

中文版内置相同的命令行程序。可在终端中先定义路径：

```sh
rmai='/Applications/RemoveMacAI 中文版.app/Contents/MacOS/RemoveMacAI'
"$rmai" --help
"$rmai" status
"$rmai" features
"$rmai" tweaks
```

下列为操作示例；`--dry-run` 仅预览。功能和调整的标识、命令及参数保留英文。

```sh
# 仅预览推荐方案
"$rmai" apply --preset recommended --dry-run

# 仅预览关闭 AI，但保留写作工具和照片清理
"$rmai" off --keep writing-tools,photos-clean-up --dry-run

# 应用两个访达调整，会请求确认
"$rmai" apply file-extensions path-bar

# 撤销这两个调整，会请求确认
"$rmai" undo file-extensions path-bar

# 只列出后台项目和可清理内容
"$rmai" background
"$rmai" clean

# 重新启用 Apple 智能，保留其他系统调整
"$rmai" on
```

`--yes` 跳过命令行确认；普通使用无需添加。`revert` 会直接开始恢复设置并引导移除描述文件，不是查询命令。已有 Homebrew 安装的 `removemacai` 命令仍可能指向英文版本；上面的完整应用路径明确调用中文版。

设备管理（MDM）可使用 `export <文件.mobileconfig>` 导出描述文件，配合 `--preset recommended`、`--keep writing-tools` 或 `--no-ai analytics personalized-ads spotlight-web`。导出只生成文件。访达、程序坞和输入等用户级调整不包含在描述文件中，需要分别在每台 Mac 上执行。

## 常见问题

**为什么切换开关后状态还没变化？** Apple 智能和系统调整需要经过“检查并应用”；带锁的项目还需要安装描述文件。后台项目开关则立即生效。

**模型已删除，系统设置为什么仍显示占用？** Apple 资源服务与磁盘文件清理之间可能存在延迟。macOS 自行安排文件移除，稍后再查看“系统设置 > 通用 > 储存空间”。

**关闭 Siri 后听写还能用吗？** 按上游说明，听写是独立设置，此工具不删除听写的语音模型。

**保留“照片清理”后在哪里使用？** 打开“照片”，选择照片并进入编辑，再使用清理工具；它不是“系统设置”中的独立总开关。

**为什么活动监视器里还有 Siri 进程？** 上游说明 macOS 27 的聚焦搜索窗口也使用 Siri 进程名；仅凭进程名不能判断 Apple 智能仍开启。受 SIP 保护的系统服务也可能继续加载。

**关闭 Apple 智能还会影响什么？** 上述功能，以及依赖 Apple 本机模型的应用、快捷指令的“使用模型”动作、视觉智能和日历自然语言编辑。具体可用性取决于 macOS 与应用版本。

**系统更新后要重做吗？** 描述文件通常持续存在。若其他设置被更新重置，应用会显示未应用，可重新选择并应用。

## 已知限制

- 本地汉化版使用本机临时签名，未经过 Apple 公证。复制到其他 Mac 后如被系统拦截，可通过“系统设置 > 隐私与安全性 > 仍要打开”放行。
- 上游 v1.0.1 文档将 macOS 27 列为支持系统，尽管可执行程序的最低启动检查为 macOS 26。本次只在 Apple 芯片、macOS 27.0.1 环境验证。
- macOS 自带授权窗口、第三方程序名称、系统返回的原始错误及命令行技术标识可能保留英文；系统窗口语言由 macOS 决定。
- 验证覆盖编译、签名、自测、页面渲染及应用启动，不通过实际关闭 AI、删除模型或清理用户文件来测试。
- 汉化基于固定的 v1.0.1 源码，后续上游版本需单独更新。

## 源码与构建

源码包保留上游 MIT 许可证和第三方授权。`Sources/removemacai/App` 为界面；`Tweaks.swift` 为 40 项系统调整；`Catalog.swift` 为 AI 功能；`tools/build-app.sh` 构建并签名中文版。描述文件标识、设置键名、JSON 字段与原版一致。中文版采用独立应用标识，操作记录仍使用上游原路径。

发布包使用 Swift 6.4 和 macOS 26.5 SDK 构建。安装 Xcode 或 Command Line Tools 后，在源码目录运行；可用 SDKROOT 指定已安装的 SDK：

```sh
SDKROOT="$(xcrun --sdk macosx26.5 --show-sdk-path)" bash tools/build-app.sh
.build/release/removemacai selftest
python3 -m venv .build/dmg-venv
.build/dmg-venv/bin/pip install -r tools/dmg-requirements.txt
.build/dmg-venv/bin/python tools/build-dmg.py
```

构建产物为 `.build/RemoveMacAI 中文版.app`。调试页面渲染沿用上游的 `REMOVEMACAI_SNAPSHOTS` 功能。预览生成与执行均包含用户明确选择的撤销项。

原项目：[omlahore/RemoveMacAI](https://github.com/omlahore/RemoveMacAI)。Apple 智能移除部分基于 [4evy/pared](https://github.com/4evy/pared)。原作者：Om Lahore。
