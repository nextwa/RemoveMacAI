import Foundation

let usage = """
  RemoveMacAI 中文版 \(version)
  精简 macOS：关闭 Apple 智能、移除相关模型、调整分析共享、广告及其他系统设置。
  系统调整支持撤销；储存空间清理的永久删除项目无法通过撤销恢复。

  Apple 智能
    removemacai                 显示当前状态，然后询问是否关闭
    removemacai status          显示功能状态及模型占用
    removemacai off [选项]      关闭 Apple 智能
        --keep a,b              保留指定功能（标识列表：removemacai features）
        --dry-run               仅预览，不更改设置
        --yes                   跳过确认
    removemacai on              重新启用 Apple 智能，保留其他系统调整
    removemacai features        列出功能标识及中文名称

  系统调整
    removemacai tweaks [--json]           列出所有调整及当前状态
    removemacai apply <标识> [选项]      应用指定调整
        --preset recommended|privacy      应用预设，也会关闭 Apple 智能
        --dry-run, --yes                  仅预览 / 跳过确认
    removemacai undo <标识>              撤销指定调整
    removemacai background [off|on <标识>]
                                         查看、关闭或开启其他应用的后台项目
    removemacai clean [<标识>]           查看可清理空间或清理指定项目
    removemacai export <文件.mobileconfig> [--preset p] [<标识>] [--keep a,b] [--no-ai]
                                         导出供设备管理（MDM）使用的描述文件

    removemacai revert          撤销 RemoveMacAI 的全部设置更改
    removemacai app             打开中文版应用

  """

var args = Array(CommandLine.arguments.dropFirst())
func flag(_ name: String) -> Bool {
  guard let i = args.firstIndex(of: name) else { return false }
  args.remove(at: i)
  return true
}
func option(_ name: String) -> String? {
  guard let i = args.firstIndex(of: name), i + 1 < args.count else { return nil }
  let value = args[i + 1]
  args.removeSubrange(i...(i + 1))
  return value
}
func presetOption() -> Preset? {
  guard let name = option("--preset") else { return nil }
  guard let preset = Preset(rawValue: name) else {
    Term.fail("没有名为“\(name)”的预设，请使用 recommended 或 privacy")
  }
  return preset
}

// Opened from Finder: the app. With arguments, or from a bare binary: the CLI.
if args.isEmpty && Bundle.main.bundleURL.pathExtension == "app" || args.first == "app" {
  guard ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26 else {
    Term.fail("RemoveMacAI 需要 macOS 26 或更新版本")
  }
  Shell.inApp = true
  RemoveMacAIApp.main()
  exit(0)
}

guard args.first == "selftest" || ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26 else {
  Term.fail("RemoveMacAI 需要 macOS 26 或更新版本")
}

switch args.first {
case "status":
  Commands.status()
case "off", nil:
  if !args.isEmpty { args.removeFirst() }
  let keep = Set((option("--keep") ?? "").split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty })
  let dryRun = flag("--dry-run")
  let yes = flag("--yes") || flag("-y")
  if let extra = args.first { Term.fail("未知选项：\(extra)") }
  exit(Commands.off(keep: keep, dryRun: dryRun, yes: yes) ? 0 : 1)
case "revert":
  Commands.revert()
case "on":
  Commands.on()
case "features":
  Commands.features()
case "tweaks":
  args.removeFirst()
  TweakCommands.list(json: flag("--json"))
case "apply", "undo":
  let command = args.removeFirst()
  let preset = presetOption()
  let dryRun = flag("--dry-run")
  let yes = flag("--yes") || flag("-y")
  if let bad = args.first(where: { $0.hasPrefix("-") }) { Term.fail("未知选项：\(bad)") }
  let ok = command == "apply"
    ? TweakCommands.apply(ids: args, preset: preset, dryRun: dryRun, yes: yes)
    : TweakCommands.undo(ids: args, dryRun: dryRun, yes: yes)
  exit(ok ? 0 : 1)
case "background":
  args.removeFirst()
  let yes = flag("--yes") || flag("-y")
  exit(TweakCommands.background(args, yes: yes) ? 0 : 1)
case "clean":
  args.removeFirst()
  let dryRun = flag("--dry-run")
  let yes = flag("--yes") || flag("-y")
  exit(TweakCommands.clean(ids: args, dryRun: dryRun, yes: yes) ? 0 : 1)
case "export":
  args.removeFirst()
  let preset = presetOption()
  let keep = Set((option("--keep") ?? "").split(separator: ",").map { String($0).trimmed }.filter { !$0.isEmpty })
  let noAI = flag("--no-ai")
  guard let path = args.first else { Term.fail("请指定要写入的文件，例如：removemacai export RemoveMacAI.mobileconfig") }
  TweakCommands.export(path: path, ids: Array(args.dropFirst()), preset: preset, keepAI: keep, noAI: noAI)
case "selftest":
  exit(selfTest() ? 0 : 1)
case "--version", "-v", "version":
  print(version)
case "help", "--help", "-h":
  print(usage, terminator: "")
default:
  print(usage, terminator: "")
  exit(1)
}
