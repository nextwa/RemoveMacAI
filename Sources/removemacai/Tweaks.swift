import Foundation

/// A sidebar section of the catalog.
enum TweakGroup: String, CaseIterable, Identifiable {
  case privacy, annoyances, apps, finder, windows, typing

  var id: String { rawValue }

  var title: String {
    switch self {
    case .privacy: return "隐私"
    case .annoyances: return "减少干扰"
    case .apps: return "Apple 应用"
    case .finder: return "访达"
    case .windows: return "程序坞与窗口"
    case .typing: return "键盘输入"
    }
  }

  var symbol: String {
    switch self {
    case .privacy: return "hand.raised"
    case .annoyances: return "bell.slash"
    case .apps: return "square.grid.2x2"
    case .finder: return "folder"
    case .windows: return "dock.rectangle"
    case .typing: return "keyboard"
    }
  }

  var summary: String {
    switch self {
    case .privacy: return "减少向 Apple 发送分析数据、搜索内容及语音录音。"
    case .annoyances: return "关闭不需要的弹窗、小组件及容易误触的功能。"
    case .apps: return "精简不常用的 Apple 应用功能。macOS 不允许直接删除此处涉及的系统应用。"
    case .finder: return "显示访达默认隐藏的内容，减少它在文件夹中留下的附加文件。"
    case .windows: return "减少程序坞的额外图标、延迟与动画，让操作更直接。"
    case .typing: return "关闭不需要的自动改写与输入替换。"
    }
  }
}

/// A named starting selection.
enum Preset: String, CaseIterable, Identifiable {
  case recommended, privacy

  var id: String { rawValue }

  var title: String {
    switch self {
    case .recommended: return "推荐方案"
    case .privacy: return "更强隐私"
    }
  }

  var summary: String {
    switch self {
    case .recommended: return "关闭 Apple 智能、分析共享及个性化广告，减少干扰，并启用常用的访达调整。"
    case .privacy: return "包含“推荐方案”的全部调整，并额外关闭 Game Center 与 Safari 搜索建议。"
    }
  }
}

/// One setting a tweak changes.
enum Change: Equatable {
  /// A restriction key the profile sets to false.
  case restriction(String)
  /// A preference the profile forces, so it can't be changed back by hand.
  case forced(String, String, PlistValue)
  /// A preference written for the current user.
  case pref(String, String, PlistValue, currentHost: Bool = false)
  /// A launchd agent in the user's session, disabled and unloaded.
  case service(String)
  /// Dock icons removed by bundle identifier.
  case dockRemove([String])
  /// ~/Library shown in Finder.
  case showLibrary

  var inProfile: Bool {
    switch self {
    case .restriction, .forced: return true
    default: return false
    }
  }

  /// The journal key; two tweaks never change the same thing.
  var key: String {
    switch self {
    case .restriction(let k): return "restriction:\(k)"
    case .forced(let d, let k, _): return "forced:\(d):\(k)"
    case .pref(let d, let k, _, let host): return "pref:\(d):\(k)" + (host ? ":currentHost" : "")
    case .service(let l): return "service:\(l)"
    case .dockRemove(let ids): return "dock:" + ids.joined(separator: ",")
    case .showLibrary: return "library"
    }
  }

  /// The equivalent command, shown before anything changes.
  var command: String {
    switch self {
    case .restriction(let k): return "profile: com.apple.applicationaccess \(k) = false"
    case .forced(let d, let k, let v): return "profile: \(d) \(k) = \(v) (locked)"
    case .pref(let d, let k, let v, let host):
      let type: String
      switch v {
      case .bool: type = "-bool"
      case .int: type = "-int"
      case .double: type = "-float"
      case .string: type = "-string"
      }
      let value: String
      if case .string(let s) = v { value = "\"\(s)\"" } else { value = v.description }
      return "defaults\(host ? " -currentHost" : "") write \(d) \"\(k)\" \(type) \(value)"
    case .service(let l): return "launchctl disable gui/$UID/\(l) && launchctl bootout gui/$UID/\(l)"
    case .dockRemove(let ids): return "remove from the Dock: " + ids.joined(separator: ", ")
    case .showLibrary: return "chflags nohidden ~/Library"
    }
  }
}

struct Tweak: Identifiable {
  let id: String
  let group: TweakGroup
  let title: String
  let detail: String
  var caveat: String? = nil
  let changes: [Change]
  /// Processes that read the setting only at launch.
  var restart: [String] = []
  var presets: Set<Preset> = []
  /// The first macOS version (major, minor) that has the setting.
  var since: (Int, Int) = (14, 0)

  var inProfile: Bool { changes.contains { $0.inProfile } }

  var supported: Bool {
    let os = ProcessInfo.processInfo.operatingSystemVersion
    return (os.majorVersion, os.minorVersion) >= since
  }
}

enum Tweaks {
  static let all: [Tweak] = [
    // MARK: Privacy
    Tweak(
      id: "analytics", group: .privacy, title: "关闭 Mac 分析",
      detail: "停止向 Apple 及应用开发者发送诊断和使用情况数据。",
      changes: [.restriction("allowDiagnosticSubmission")], presets: [.recommended, .privacy]),
    Tweak(
      id: "personalized-ads", group: .privacy, title: "关闭个性化广告",
      detail: "阻止 Apple 根据你的应用使用行为，在 App Store、新闻及股市中投放个性化广告。",
      changes: [.restriction("allowApplePersonalizedAdvertising")], presets: [.recommended, .privacy]),
    Tweak(
      id: "improve-siri", group: .privacy, title: "关闭“改进 Siri 与听写”",
      detail: "停止允许 Apple 储存和评估你的 Siri 请求与听写录音。",
      changes: [.forced("com.apple.assistant.support", "Siri Data Sharing Opt-In Status", .int(2))],
      presets: [.recommended, .privacy]),
    Tweak(
      id: "improve-search", group: .privacy, title: "关闭“改进搜索”",
      detail: "停止允许 Apple 保留你的聚焦搜索、Safari 和查询内容来改进搜索服务。",
      changes: [.forced("com.apple.assistant.support", "Search Queries Data Sharing Status", .int(2))],
      presets: [.recommended, .privacy]),
    Tweak(
      id: "spotlight-web", group: .privacy, title: "关闭聚焦搜索的互联网结果",
      detail: "让聚焦搜索保留在本机，不再向 Apple 发送搜索内容以获取网络建议。",
      changes: [.restriction("allowSpotlightInternetResults")], presets: [.recommended, .privacy]),
    Tweak(
      id: "lookup-suggestions", group: .privacy, title: "关闭“查询”建议",
      detail: "阻止“查询”功能将你选中的词语发送给 Apple 以获取网络结果。",
      changes: [.forced("com.apple.lookup.shared", "LookupSuggestionsDisabled", .bool(true))],
      presets: [.recommended, .privacy]),
    Tweak(
      id: "safari-suggestions", group: .privacy, title: "关闭 Safari 搜索建议",
      detail: "阻止 Safari 为提供建议，将地址栏中尚在输入的内容发送给搜索引擎和 Apple。",
      caveat: "输入时，地址栏将不再提供搜索建议。",
      changes: [
        .forced("com.apple.Safari", "UniversalSearchEnabled", .bool(false)),
        .forced("com.apple.Safari", "SuppressSearchSuggestions", .bool(true)),
      ], presets: [.privacy]),
    Tweak(
      id: "game-center", group: .privacy, title: "关闭 Game Center（游戏中心）",
      detail: "关闭 Game Center，同时关闭其登录提示、好友请求及通知。",
      caveat: "依赖 Game Center 的游戏将无法使用其进度保存或在线游戏功能。",
      changes: [.restriction("allowGameCenter")], presets: [.privacy]),

    // MARK: Annoyances
    Tweak(
      id: "click-to-desktop", group: .annoyances, title: "关闭“点按壁纸显示桌面”",
      detail: "避免误点桌面壁纸时，所有窗口移开以显示桌面。",
      changes: [.pref("com.apple.WindowManager", "EnableStandardClickToShowDesktop", .bool(false))],
      presets: [.recommended]),
    Tweak(
      id: "desktop-widgets", group: .annoyances, title: "隐藏桌面小组件",
      detail: "隐藏桌面小组件，包括台前调度模式下的小组件。",
      changes: [
        .pref("com.apple.WindowManager", "StandardHideWidgets", .bool(true)),
        .pref("com.apple.WindowManager", "StageManagerHideWidgets", .bool(true)),
      ]),
    Tweak(
      id: "media-keys", group: .annoyances, title: "阻止播放键打开“音乐”",
      detail: "没有其他内容播放时，按播放键不再自动启动“音乐”应用。",
      caveat: "之后不能再用播放键直接启动“音乐”。",
      changes: [.service("com.apple.rcd")], presets: [.recommended]),
    Tweak(
      id: "iphone-mirroring", group: .annoyances, title: "关闭 iPhone 镜像",
      detail: "禁用 iPhone 镜像，隐藏相关应用入口及提示。",
      changes: [.restriction("allowiPhoneMirroring")], since: (15, 0)),

    // MARK: Apple apps
    Tweak(
      id: "music-classic", group: .apps, title: "关闭“音乐”中的 Apple Music 服务",
      detail: "让“音乐”主要用于播放自己的资料库，移除商店和订阅提示。",
      caveat: "Apple Music 订阅用户将无法使用流媒体播放。",
      changes: [.restriction("allowMusicService")]),
    Tweak(
      id: "book-store", group: .apps, title: "关闭图书商店",
      detail: "隐藏“图书”应用中的商店，保留你已有的图书。",
      changes: [.restriction("allowBookstore")], since: (15, 0)),
    Tweak(
      id: "dock-apple-apps", group: .apps, title: "从程序坞移除部分 Apple 应用",
      detail: "从程序坞移除新闻、TV、音乐、播客、图书、无边记、地图和股市的图标。应用本身仍保留安装。",
      changes: [.dockRemove([
        "com.apple.news", "com.apple.TV", "com.apple.Music", "com.apple.podcasts", "com.apple.iBooksX",
        "com.apple.freeform", "com.apple.Maps", "com.apple.stocks",
      ])], restart: ["Dock"]),

    // MARK: Finder
    Tweak(
      id: "file-extensions", group: .finder, title: "显示文件扩展名",
      detail: "显示文件的完整名称及扩展名，方便辨别实际文件类型。",
      changes: [.pref(Prefs.global, "AppleShowAllExtensions", .bool(true))], restart: ["Finder"],
      presets: [.recommended, .privacy]),
    Tweak(
      id: "hidden-files", group: .finder, title: "显示隐藏文件",
      detail: "显示 macOS 默认隐藏的文件，例如 .gitignore 和 .zshrc。也可按 Command–Shift–句号切换。",
      changes: [.pref("com.apple.finder", "AppleShowAllFiles", .bool(true))], restart: ["Finder"]),
    Tweak(
      id: "path-bar", group: .finder, title: "显示路径栏",
      detail: "在访达窗口底部显示当前文件夹的位置。",
      changes: [.pref("com.apple.finder", "ShowPathbar", .bool(true))], restart: ["Finder"],
      presets: [.recommended]),
    Tweak(
      id: "status-bar", group: .finder, title: "显示状态栏",
      detail: "在访达窗口底部显示项目数量及可用空间。",
      changes: [.pref("com.apple.finder", "ShowStatusBar", .bool(true))], restart: ["Finder"]),
    Tweak(
      id: "folders-first", group: .finder, title: "按名称排序时文件夹在前",
      detail: "按名称排序时，将文件夹排列在文件之前。",
      changes: [.pref("com.apple.finder", "_FXSortFoldersFirst", .bool(true))], restart: ["Finder"],
      presets: [.recommended]),
    Tweak(
      id: "search-this-folder", group: .finder, title: "默认搜索当前文件夹",
      detail: "让访达默认搜索当前文件夹，而不是整台 Mac。",
      changes: [.pref("com.apple.finder", "FXDefaultSearchScope", .string("SCcf"))], restart: ["Finder"]),
    Tweak(
      id: "extension-warning", group: .finder, title: "关闭修改扩展名的确认提示",
      detail: "修改文件扩展名时，访达不再逐次弹出确认提示。",
      changes: [.pref("com.apple.finder", "FXEnableExtensionChangeWarning", .bool(false))], restart: ["Finder"]),
    Tweak(
      id: "path-in-title", group: .finder, title: "在标题栏显示完整路径",
      detail: "在访达窗口顶部显示当前文件夹的完整路径。",
      changes: [.pref("com.apple.finder", "_FXShowPosixPathInTitle", .bool(true))], restart: ["Finder"]),
    Tweak(
      id: "network-ds-store", group: .finder, title: "不在网络磁盘写入 .DS_Store",
      detail: "阻止访达在其他电脑或 NAS 的共享文件夹中写入 .DS_Store 文件。",
      changes: [.pref("com.apple.desktopservices", "DSDontWriteNetworkStores", .bool(true))],
      presets: [.recommended]),
    Tweak(
      id: "trash-30-days", group: .finder, title: "自动删除废纸篓中超过 30 天的项目",
      detail: "自动彻底删除已在废纸篓中保留 30 天的项目，减少磁盘占用。",
      changes: [.pref("com.apple.finder", "FXRemoveOldTrashItems", .bool(true))], restart: ["Finder"]),
    Tweak(
      id: "save-locally", group: .finder, title: "默认将新文稿存到本机",
      detail: "保存对话框默认选择本机位置，而不是 iCloud 云盘。",
      changes: [.pref(Prefs.global, "NSDocumentSaveNewDocumentsToCloud", .bool(false))]),
    Tweak(
      id: "expanded-save", group: .finder, title: "默认展开保存对话框",
      detail: "打开保存对话框时，直接显示完整的文件夹浏览界面。",
      changes: [.pref(Prefs.global, "NSNavPanelExpandedStateForSaveMode", .bool(true))]),
    Tweak(
      id: "show-library", group: .finder, title: "显示用户资源库文件夹",
      detail: "在个人文件夹中显示默认隐藏的资源库（Library）文件夹。",
      changes: [.showLibrary]),

    // MARK: Dock and windows
    Tweak(
      id: "dock-recents", group: .windows, title: "隐藏程序坞中的最近使用应用",
      detail: "不再在程序坞中自动显示最近打开的应用。",
      changes: [.pref("com.apple.dock", "show-recents", .bool(false))], restart: ["Dock"],
      presets: [.recommended]),
    Tweak(
      id: "dock-delay", group: .windows, title: "取消程序坞自动隐藏后的显示延迟",
      detail: "将指针移至屏幕边缘时立即显示程序坞，无需等待约半秒。",
      changes: [.pref("com.apple.dock", "autohide-delay", .double(0))], restart: ["Dock"]),
    Tweak(
      id: "dock-bounce", group: .windows, title: "关闭程序坞图标的启动弹跳",
      detail: "启动应用时，程序坞图标不再弹跳。",
      changes: [.pref("com.apple.dock", "launchanim", .bool(false))], restart: ["Dock"]),
    Tweak(
      id: "minimize-to-app", group: .windows, title: "将窗口最小化到应用图标",
      detail: "将最小化的窗口收进对应应用图标，减少程序坞中的独立窗口缩略图。",
      changes: [.pref("com.apple.dock", "minimize-to-application", .bool(true))], restart: ["Dock"]),
    Tweak(
      id: "window-animations", group: .windows, title: "关闭窗口打开动画",
      detail: "直接显示新窗口，跳过缩放动画。",
      changes: [.pref(Prefs.global, "NSAutomaticWindowAnimationsEnabled", .bool(false))]),
    Tweak(
      id: "tile-margins", group: .windows, title: "移除平铺窗口之间的间距",
      detail: "移除贴靠屏幕边缘平铺时，窗口周围的留白。",
      changes: [.pref("com.apple.WindowManager", "EnableTiledWindowMargins", .bool(false))], since: (15, 0)),
    Tweak(
      id: "screenshot-shadow", group: .windows, title: "移除窗口截图阴影",
      detail: "截取单个窗口时，不再保留周围的大面积阴影。",
      changes: [.pref("com.apple.screencapture", "disable-shadow", .bool(true))], restart: ["SystemUIServer"]),

    // MARK: Typing
    Tweak(
      id: "autocorrect", group: .typing, title: "关闭自动纠正拼写",
      detail: "停止在输入过程中自动纠正词语拼写。",
      changes: [.pref(Prefs.global, "NSAutomaticSpellingCorrectionEnabled", .bool(false))]),
    Tweak(
      id: "smart-punctuation", group: .typing, title: "关闭智能引号和破折号",
      detail: "保留直引号和连续两个连字符，不自动替换为弯引号或破折号，适合代码和终端输入。",
      changes: [
        .pref(Prefs.global, "NSAutomaticQuoteSubstitutionEnabled", .bool(false)),
        .pref(Prefs.global, "NSAutomaticDashSubstitutionEnabled", .bool(false)),
      ]),
    Tweak(
      id: "double-space-period", group: .typing, title: "关闭连按两次空格输入句号",
      detail: "连续输入两个空格时，不再自动替换为句号。",
      changes: [.pref(Prefs.global, "NSAutomaticPeriodSubstitutionEnabled", .bool(false))]),
    Tweak(
      id: "auto-capitalize", group: .typing, title: "关闭自动大写",
      detail: "停止自动将句首单词的首字母改为大写。",
      changes: [.pref(Prefs.global, "NSAutomaticCapitalizationEnabled", .bool(false))]),
    Tweak(
      id: "key-repeat", group: .typing, title: "长按按键时重复输入",
      detail: "长按按键时连续输入该字符，不再弹出重音字符菜单。",
      caveat: "需要输入重音字符时，请改用 Option 快捷键或字符检视器。",
      changes: [.pref(Prefs.global, "ApplePressAndHoldEnabled", .bool(false))]),
  ]

  static func tweak(_ id: String) -> Tweak? { all.first { $0.id == id } }

  /// Maximum privacy builds on Recommended.
  static func preset(_ preset: Preset) -> [Tweak] {
    let names: Set<Preset> = preset == .privacy ? [.recommended, .privacy] : [preset]
    return all.filter { !$0.presets.isDisjoint(with: names) && $0.supported }
  }
}
