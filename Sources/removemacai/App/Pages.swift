import SwiftUI

// MARK: - Overview

struct OverviewView: View {
  @Environment(AppModel.self) private var model

  var body: some View {
    Form {
      Section {
        StatusRow(
          symbol: "apple.intelligence", title: "Apple 智能",
          value: aiText, good: model.currentAI != nil
        ) { model.page = .intelligence }
        StatusRow(
          symbol: "slider.horizontal.3", title: "系统调整",
          value: "已应用 \(model.appliedCount) 项，共 \(model.availableCount) 项", good: model.appliedCount > 0
        ) { model.page = .group(.privacy) }
        StatusRow(
          symbol: "gearshape.2", title: "其他应用的后台项目",
          value: backgroundText, good: model.background.isEmpty || !model.backgroundOff.isEmpty
        ) { model.page = .background }
        StatusRow(
          symbol: "internaldrive", title: "可回收的储存空间",
          value: model.scanned ? Term.size(model.storage.reduce(0) { $0 + $1.bytes }) : "尚未扫描", good: false
        ) { model.page = .storage }
      } header: {
        VStack(alignment: .leading, spacing: 18) {
          VStack(alignment: .leading, spacing: 6) {
            Text("为这台 Mac 做减法")
              .font(.system(size: 28, weight: .bold))
              .foregroundStyle(.primary)
            Text("关闭 Apple 智能、分析数据收集及部分系统弹窗，回收磁盘空间。系统调整可在应用前逐项检查，并可撤销。")
              .font(.body)
              .foregroundStyle(.secondary)
              .fixedSize(horizontal: false, vertical: true)
            Text("Apple 智能移除功能基于 4evy 的 [pared](https://github.com/4evy/pared) 项目。")
              .font(.callout)
              .foregroundStyle(.tertiary)
              .tint(.secondary)
          }
          Text("本机状态")
        }
        .textCase(nil)
        .padding(.top, 4)
      }

      Section {
        ForEach(Preset.allCases) { preset in
          HStack(alignment: .top, spacing: 14) {
            Image(systemName: preset == .recommended ? "checkmark.seal" : "hand.raised")
              .font(.title2).foregroundStyle(.tint).frame(width: 28)
            VStack(alignment: .leading, spacing: 3) {
              Text(preset.title).font(.headline)
              Text(preset.summary).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
              Text("\(Tweaks.preset(preset).count) 项系统调整，并关闭 Apple 智能")
                .font(.caption).foregroundStyle(.tertiary)
            }
            Spacer()
            Button("选择…") {
              model.choose(preset)
              model.reviewing = true
            }
          }
          .padding(.vertical, 4)
        }
      } header: {
        Text("从预设方案开始")
      } footer: {
        Footer("预设会在已应用的调整上增加选项，检查并确认后才会生效。也可在侧边栏逐项选择。")
      }
    }
    .formStyle(.grouped)
    .navigationTitle("概览")
  }

  var aiText: String {
    if model.currentAI != nil { return model.modelTotal > 0 ? "已关闭，磁盘上仍有 \(Term.size(model.modelTotal)) 的模型" : "已关闭" }
    if model.loadingModels { return "已开启" }
    return model.modelTotal > 0 ? "已开启，模型占用 \(Term.size(model.modelTotal))" : "已开启"
  }

  var backgroundText: String {
    let n = model.background.count
    if n == 0 { return "无" }
    let off = model.backgroundOff.count
    return off > 0 ? "共 \(n) 项，已关闭 \(off) 项" : "\(n) 项运行中"
  }
}

struct StatusRow: View {
  let symbol: String
  let title: String
  let value: String
  let good: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 12) {
        Image(systemName: symbol).frame(width: 22).foregroundStyle(.secondary)
        Text(title)
        Spacer()
        Text(value).foregroundStyle(good ? Color.green : Color.secondary)
        Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.tertiary)
      }
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }
}

// MARK: - Apple Intelligence

struct IntelligenceView: View {
  @Environment(AppModel.self) private var model

  var body: some View {
    @Bindable var model = model
    Form {
      Section {
        Toggle(isOn: $model.aiOff) {
          VStack(alignment: .leading, spacing: 3) {
            Text("关闭 Apple 智能").font(.headline)
            Text("关闭 Siri、写作工具、智绘表情、图乐园、摘要及 ChatGPT 集成功能，删除相关模型，并阻止 macOS 再次下载。")
              .foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
          }
        }
        .toggleStyle(.switch)
      } footer: {
        Footer("此操作需要在 macOS 中批准安装配置描述文件，撤销可恢复相关设置。本功能基于 4evy 的 pared 项目，该项目率先梳理了 Apple 的资源服务与模型集。")
      }

      Section {
        ForEach(Catalog.features, id: \.id) { feature in
          Toggle(isOn: Binding(
            get: { model.aiKept.contains(feature.id) },
            set: { if $0 { model.aiKept.insert(feature.id) } else { model.aiKept.remove(feature.id) } }
          )) {
            VStack(alignment: .leading, spacing: 2) {
              Text(feature.title)
              Text(stateText(feature.id)).font(.caption).foregroundStyle(.secondary)
            }
          }
          .disabled(!model.aiOff)
        }
      } header: {
        Text("保留以下功能")
      } footer: {
        Footer("保留某项功能时，也会保留该功能所需的模型。")
      }

      Section {
        if model.loadingModels {
          HStack { ProgressView().controlSize(.small); Text("正在查询 Apple 资源服务…").foregroundStyle(.secondary) }
        } else if !model.modelsAvailable {
          Text("Apple 资源服务未响应，暂时无法确定模型大小。").foregroundStyle(.secondary)
        } else {
          ForEach(Catalog.modelSets, id: \.name) { set in
            LabeledContent(set.title) {
              let bytes = model.modelBytes[set.name] ?? 0
              Text(bytes > 0 ? Term.size(bytes) : "无").foregroundStyle(bytes > 0 ? .primary : .secondary)
            }
          }
          LabeledContent("合计") { Text(Term.size(model.modelTotal)).fontWeight(.semibold) }
          if model.currentAI != nil && model.modelTotal > 0 {
            HStack {
              Text("Apple 智能已关闭，但这些模型仍在磁盘上。").foregroundStyle(.secondary)
              Spacer()
              Button("删除剩余模型") { model.deleteLeftoverModels() }
            }
          }
        }
      } header: {
        Text("磁盘上的模型")
      } footer: {
        Footer("macOS 会自行安排文件删除，因此移除后“储存空间”可能暂时仍显示这些文件的占用。")
      }
    }
    .formStyle(.grouped)
    .navigationTitle("Apple 智能")
  }

  func stateText(_ id: String) -> String {
    switch model.featureStates[id] {
    case .lockedOff?: return "已关闭，由 RemoveMacAI 锁定"
    case .off?: return "已关闭"
    case .on?: return "已开启"
    default: return model.loadingModels ? "正在检查…" : "未知"
    }
  }
}

// MARK: - Tweak groups

struct TweakGroupView: View {
  @Environment(AppModel.self) private var model
  let group: TweakGroup

  var tweaks: [Tweak] { Tweaks.all.filter { $0.group == group } }

  var body: some View {
    Form {
      Section {
        ForEach(tweaks) { TweakRow(tweak: $0) }
      } header: {
        Text(group.summary).font(.body).foregroundStyle(.secondary).textCase(nil)
      } footer: {
        if tweaks.contains(where: \.inProfile) {
          Footer("带锁图标的设置通过 RemoveMacAI 描述文件应用，需要在 macOS 中手动批准。")
        }
      }
    }
    .formStyle(.grouped)
    .navigationTitle(group.title)
    .toolbar {
      ToolbarItem {
        Menu {
          Button("全选") { for t in tweaks where t.supported { model.toggle(t, true) } }
          Button("选择推荐项") {
            for t in tweaks {
              let recommended = t.presets.contains(.recommended)
              if model.state(t) == .partial && !recommended {
                model.leave(t)
              } else {
                model.toggle(t, recommended || model.state(t) == .applied)
              }
            }
          }
          Button("取消全选") { for t in tweaks { model.toggle(t, false) } }
        } label: {
          Label("选择", systemImage: "checklist")
        }
      }
    }
  }
}

struct TweakRow: View {
  @Environment(AppModel.self) private var model
  let tweak: Tweak

  var body: some View {
    let state = model.state(tweak)
    let wanted = model.isOn(tweak)
    Toggle(isOn: Binding(get: { wanted }, set: { model.toggle(tweak, $0) })) {
      VStack(alignment: .leading, spacing: 3) {
        HStack(spacing: 6) {
          Text(tweak.title)
          if tweak.inProfile {
            Image(systemName: "lock.fill").font(.caption2).foregroundStyle(.tertiary)
              .help("由 RemoveMacAI 描述文件锁定")
          }
          if let note = pendingNote(state: state, wanted: wanted, undoes: model.undoes(tweak)) {
            Text(note).font(.caption.weight(.medium)).foregroundStyle(.tint)
          }
        }
        Text(tweak.detail).font(.callout).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
        if let caveat = tweak.caveat {
          Label(caveat, systemImage: "exclamationmark.triangle").font(.caption).foregroundStyle(.orange)
        }
        if state == .managed {
          Text("由本机的其他描述文件管理。").font(.caption).foregroundStyle(.secondary)
        } else if state == .unsupported {
          Text("需要 macOS \(tweak.since.0).\(tweak.since.1) 或更新版本。").font(.caption).foregroundStyle(.secondary)
        } else if state == .partial {
          Text("已部分应用。只有操作此开关才会改变当前状态。").font(.caption).foregroundStyle(.secondary)
        }
      }
      .padding(.vertical, 2)
    }
    .toggleStyle(.switch)
    .disabled(state == .managed || state == .unsupported)
  }

  func pendingNote(state: TweakState, wanted: Bool, undoes: Bool) -> String? {
    if wanted && state != .applied { return "确认后应用" }
    if undoes { return "确认后撤销" }
    return nil
  }
}

// MARK: - Background items

struct BackgroundView: View {
  @Environment(AppModel.self) private var model

  var body: some View {
    Form {
      Section {
        if model.background.isEmpty {
          Text("未发现其他应用的后台项目。").foregroundStyle(.secondary)
        }
        ForEach(model.background) { item in
          Toggle(isOn: Binding(
            get: { !model.backgroundOff.contains(item.id) },
            set: { model.setBackground(item, off: !$0) }
          )) {
            VStack(alignment: .leading, spacing: 2) {
              HStack(spacing: 6) {
                Text(item.owner)
                if item.system {
                  Text("所有用户").font(.caption2.weight(.medium)).padding(.horizontal, 5).padding(.vertical, 1)
                    .background(Capsule().fill(.quaternary))
                }
              }
              Text(item.label).font(.caption.monospaced()).foregroundStyle(.secondary)
              Text(item.program).font(.caption2.monospaced()).foregroundStyle(.tertiary)
                .lineLimit(1).truncationMode(.middle)
              if let warning = item.warning {
                Label(warning, systemImage: "exclamationmark.triangle").font(.caption).foregroundStyle(.orange)
              }
            }
          }
          .toggleStyle(.switch)
          .disabled(model.backgroundBusy)
        }
      } header: {
        Text("这里列出其他应用安装的更新程序、辅助程序和代理，它们可能在主应用关闭后继续运行。关闭开关会立即生效。关闭更新程序会停止其后台更新；VPN、Docker 等应用的辅助程序可能是正常运行所必需的。")
          .font(.body).foregroundStyle(.secondary).textCase(nil)
      } footer: {
        Footer("标注“所有用户”的项目需要输入管理员密码。Apple 自带的后台服务受系统完整性保护（SIP）保护，RemoveMacAI 不会修改它们。")
      }
    }
    .formStyle(.grouped)
    .navigationTitle("后台项目")
    .toolbar {
      ToolbarItem {
        Button { model.loadBackground() } label: { Label("重新载入", systemImage: "arrow.clockwise") }
      }
    }
  }
}

// MARK: - Storage

struct StorageView: View {
  @Environment(AppModel.self) private var model
  @State private var confirming = false

  /// Selected items that are deleted right away instead of going to the Trash.
  var permanentChosen: [String] {
    model.storage.filter { model.storageChosen.contains($0.id) && $0.permanent }.map(\.title)
  }

  var body: some View {
    Form {
      if !model.scanned {
        Section {
          HStack(spacing: 14) {
            Image(systemName: "internaldrive").font(.title).foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 3) {
              Text("查找可回收的空间").font(.headline)
              Text("查找旧安装程序、航拍壁纸视频、Xcode 残留、应用缓存和时间机器快照。扫描本身不会移动或删除文件。")
                .foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            if model.scanning { ProgressView().controlSize(.small) } else { Button("扫描") { model.scan() } }
          }
          .padding(.vertical, 4)
        }
      } else {
        Section {
          if model.storage.isEmpty {
            Text("没有可清理的项目。").foregroundStyle(.secondary)
          }
          ForEach(model.storage) { item in
            HStack(alignment: .top, spacing: 10) {
              Toggle("", isOn: Binding(
                get: { model.storageChosen.contains(item.id) },
                set: { if $0 { model.storageChosen.insert(item.id) } else { model.storageChosen.remove(item.id) } }
              ))
              .toggleStyle(.checkbox)
              .labelsHidden()
              VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                Text(item.detail).font(.callout).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                if let caveat = item.caveat {
                  Label(caveat, systemImage: "info.circle").font(.caption).foregroundStyle(.secondary)
                }
              }
              Spacer()
              Text(item.kind == .snapshots ? "\(item.count) 个快照" : Term.size(item.bytes))
                .monospacedDigit().foregroundStyle(.secondary)
            }
            .padding(.vertical, 2)
          }
        } header: {
          HStack {
            Text("普通文件移入废纸篓，清倒后才会彻底删除；模拟器与快照会立即永久删除。").textCase(nil)
            Spacer()
            if model.scanning { ProgressView().controlSize(.small) } else { Button("重新扫描") { model.scan() }.buttonStyle(.link) }
          }
        }
        Section {
          HStack {
            if let message = model.cleanMessage {
              Text(message).foregroundStyle(.secondary)
            } else {
              Text(model.storageChosen.isEmpty ? "尚未选择项目" : "已选：\(Term.size(model.chosenBytes))").monospacedDigit()
            }
            Spacer()
            if model.cleaning { ProgressView().controlSize(.small) }
            Button(permanentChosen.isEmpty ? "移到废纸篓…" : "移除…") { confirming = true }
              .buttonStyle(.borderedProminent)
              .disabled(model.storageChosen.isEmpty || model.cleaning)
          }
        }
      }
    }
    .formStyle(.grouped)
    .navigationTitle("储存空间")
    .confirmationDialog(
      permanentChosen.isEmpty ? "将所选项目移到废纸篓？" : "移除所选项目？",
      isPresented: $confirming
    ) {
      Button(permanentChosen.isEmpty ? "移到废纸篓" : "移除") { model.clean() }
    } message: {
      Text("约 \(Term.size(model.chosenBytes))。移动仅管理员可操作的项目时，需要输入密码。"
        + (permanentChosen.isEmpty ? "" : "其中，\(permanentChosen.joined(separator: "、"))将立即永久删除，不会移入废纸篓。"))
    }
  }
}

// MARK: - Undo

struct ChangesView: View {
  @Environment(AppModel.self) private var model
  @State private var confirming = false

  var body: some View {
    Form {
      Section("配置描述文件") {
        if model.snapshot.profile.on {
          LabeledContent("RemoveMacAI 描述文件", value: "已安装")
          if model.currentAI != nil { Label("Apple 智能已关闭", systemImage: "apple.intelligence") }
          ForEach(model.snapshot.profile.tweaks.sorted(), id: \.self) { id in
            Label(Tweaks.tweak(id)?.title ?? id, systemImage: "lock.fill")
          }
        } else {
          Text("尚未安装。").foregroundStyle(.secondary)
        }
      }
      Section("其他更改") {
        let entries = model.journal.entries.sorted { $0.value.date > $1.value.date }
        if entries.isEmpty {
          Text("无。").foregroundStyle(.secondary)
        }
        ForEach(entries, id: \.key) { key, entry in
          LabeledContent {
            Text(entry.date, style: .date).foregroundStyle(.secondary)
          } label: {
            VStack(alignment: .leading, spacing: 2) {
              Text(title(entry.tweak))
              Text(key).font(.caption.monospaced()).foregroundStyle(.tertiary)
            }
          }
        }
      }
      Section {
        HStack {
          Text("将设置恢复至 RemoveMacAI 修改前的状态，并移除描述文件。")
            .foregroundStyle(.secondary)
          Spacer()
          Button("撤销全部更改…", role: .destructive) { confirming = true }
            .disabled(!model.snapshot.profile.on && model.journal.entries.isEmpty)
        }
      }
    }
    .formStyle(.grouped)
    .navigationTitle("撤销更改")
    .confirmationDialog("撤销 RemoveMacAI 所做的全部设置更改？", isPresented: $confirming) {
      Button("撤销全部更改", role: .destructive) { model.undoEverything() }
    } message: {
      Text("macOS 会要求你在“系统设置”中移除描述文件。已删除的模型会在使用相关功能时重新下载；废纸篓中的文件不会自动还原。")
    }
  }

  func title(_ id: String) -> String {
    if let t = Tweaks.tweak(id) { return t.title }
    if let item = model.background.first(where: { $0.id == id }) { return "后台项目：\(item.owner)" }
    return id
  }
}

struct Footer: View {
  let text: String
  init(_ text: String) { self.text = text }

  var body: some View {
    Text(text)
      .font(.callout)
      .foregroundStyle(.secondary)
      .multilineTextAlignment(.leading)
      .frame(maxWidth: .infinity, alignment: .leading)
      .fixedSize(horizontal: false, vertical: true)
  }
}
