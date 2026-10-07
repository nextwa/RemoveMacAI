import AppKit
import SwiftUI

struct RemoveMacAIApp: App {
  @NSApplicationDelegateAdaptor private var delegate: AppDelegate
  @State private var model = AppModel()

  var body: some Scene {
    Window("RemoveMacAI 中文版", id: "main") {
      ContentView()
        .environment(model)
        .frame(minWidth: 860, minHeight: 600)
    }
    .defaultSize(width: 1000, height: 700)
    .commands {
      CommandGroup(replacing: .newItem) {}
      CommandGroup(replacing: .appInfo) {
        Button("关于 RemoveMacAI") { AppDelegate.showAbout() }
      }
      CommandGroup(after: .toolbar) {
        Button("重新载入") { model.reload(resetChoices: true) }.keyboardShortcut("r")
      }
      CommandGroup(replacing: .help) {
        Link("RemoveMacAI 的 GitHub 项目", destination: URL(string: "https://github.com/nextwa/RemoveMacAI")!)
        Link("报告问题", destination: URL(string: "https://github.com/nextwa/RemoveMacAI/issues/new/choose")!)
      }
    }
  }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    // A bare binary run from Terminal has no bundle, so it must ask to be a real app.
    NSApp.setActivationPolicy(.regular)
    NSApp.activate(ignoringOtherApps: true)
    #if DEBUG
      if let dir = ProcessInfo.processInfo.environment["REMOVEMACAI_SNAPSHOTS"] { Snapshots.run(into: dir) }
    #endif
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

  static func showAbout() {
    let credits = NSMutableAttributedString(
      string: "精简 macOS，并支持撤销设置更改。\n\nApple 智能移除功能基于 4evy 的 pared 项目，该项目率先梳理了 Apple 的资源服务与模型集。",
      attributes: [.font: NSFont.systemFont(ofSize: 11), .foregroundColor: NSColor.secondaryLabelColor])
    NSApp.orderFrontStandardAboutPanel(options: [
      .applicationName: "RemoveMacAI 中文版",
      .applicationVersion: version,
      .version: "",
      .credits: credits,
    ])
  }
}
