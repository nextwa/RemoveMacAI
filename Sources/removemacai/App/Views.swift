import SwiftUI

struct ContentView: View {
  @Environment(AppModel.self) private var model

  var body: some View {
    @Bindable var model = model
    NavigationSplitView {
      Sidebar()
        .navigationSplitViewColumnWidth(min: 210, ideal: 230)
    } detail: {
      DetailView(page: model.page ?? .overview)
        .safeAreaInset(edge: .bottom, spacing: 0) {
          if model.pendingCount > 0 { PendingBar() }
        }
    }
    .sheet(isPresented: $model.reviewing) { ReviewSheet() }
    .sheet(isPresented: Binding(get: { model.run != nil }, set: { if !$0 { model.dismissRun() } })) {
      RunSheet()
    }
  }
}

struct DetailView: View {
  let page: Page

  var body: some View {
    switch page {
    case .overview: OverviewView()
    case .intelligence: IntelligenceView()
    case .group(let group): TweakGroupView(group: group)
    case .background: BackgroundView()
    case .storage: StorageView()
    case .changes: ChangesView()
    }
  }
}

// MARK: - Sidebar

struct Sidebar: View {
  @Environment(AppModel.self) private var model

  var body: some View {
    @Bindable var model = model
    List(selection: $model.page) {
      row(.overview, badge: 0)
      Section("系统精简") {
        row(.intelligence, badge: model.aiPending ? 1 : 0)
        ForEach(TweakGroup.allCases) { group in
          row(.group(group), badge: model.pending(in: group))
        }
        row(.background, badge: 0)
      }
      Section("清理与恢复") {
        row(.storage, badge: 0)
        row(.changes, badge: 0)
      }
    }
    .listStyle(.sidebar)
  }

  func row(_ page: Page, badge: Int) -> some View {
    Label(page.title, systemImage: page.symbol)
      .badge(badge)
      .tag(page)
  }
}

// MARK: - Bottom bar and review

struct PendingBar: View {
  @Environment(AppModel.self) private var model

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: "circle.fill").font(.system(size: 7)).foregroundStyle(.tint)
      Text(model.pendingCount == 1 ? "有 1 项更改待应用" : "有 \(model.pendingCount) 项更改待应用")
        .font(.callout.weight(.medium))
      Spacer()
      Button("放弃更改") { model.discard() }
      Button("检查并应用…") { model.reviewing = true }
        .buttonStyle(.borderedProminent)
        .keyboardShortcut(.defaultAction)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
    .background(.bar)
    .overlay(alignment: .top) { Divider() }
  }
}

struct ReviewSheet: View {
  @Environment(AppModel.self) private var model
  @State private var plan: Plan?

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      VStack(alignment: .leading, spacing: 4) {
        Text("检查更改").font(.title2.weight(.semibold))
        Text("点击“应用”后才会修改设置。此处的设置更改之后均可撤销。")
          .foregroundStyle(.secondary)
      }
      .padding(20)
      Divider()
      if let plan {
        List {
          if !plan.apply.isEmpty {
            Section("应用") {
              ForEach(plan.apply) { t in ChangeRow(tweak: t, adding: true) }
            }
          }
          if !plan.revert.isEmpty {
            Section("撤销更改") {
              ForEach(plan.revert) { t in ChangeRow(tweak: t, adding: false) }
            }
          }
          if model.aiPending || !plan.models.isEmpty {
            Section("Apple 智能") {
              if model.aiPending, let kept = model.targetAI {
                Label(
                  kept.isEmpty ? "关闭全部功能" : "关闭其他功能，保留所选的 \(kept.count) 项功能",
                  systemImage: "apple.intelligence")
              } else if model.aiPending {
                Label("重新启用 Apple 智能。使用相关功能时，macOS 会重新下载所需模型。", systemImage: "arrow.uturn.backward")
              }
              if !plan.models.isEmpty {
                let bytes = model.modelBytes(plan.models)
                Label(
                  bytes.map { $0 > 0 ? "删除模型，约 \(Term.size($0))" : "请求 macOS 完成剩余模型文件的清理" }
                    ?? "删除模型",
                  systemImage: "trash")
              }
            }
          }
          if let profile = plan.profile {
            Section("系统授权") {
              Label(
                profile.isEmpty
                  ? "请在“系统设置”中移除 RemoveMacAI 描述文件。"
                  : "请在“系统设置”中批准安装 RemoveMacAI 描述文件。macOS 要求你手动确认，完成后带锁的设置才会更改。",
                systemImage: "checkmark.shield")
            }
          }
        }
        .listStyle(.inset)
      } else {
        ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      Divider()
      HStack {
        Spacer()
        Button("取消", role: .cancel) { model.reviewing = false }
          .keyboardShortcut(.cancelAction)
        Button("应用") { model.apply() }
          .buttonStyle(.borderedProminent)
          .keyboardShortcut(.defaultAction)
          .disabled(plan?.isEmpty ?? true)
      }
      .padding(16)
    }
    .frame(width: 600, height: 560)
    .task {
      let wanted = model.wanted
      let ai = model.targetAI
      let snapshot = model.snapshot
      let undo = model.touched
      plan = await Task.detached { Plan.make(wanted: wanted, ai: ai, undo: undo, snapshot: snapshot) }.value
    }
  }
}

struct ChangeRow: View {
  let tweak: Tweak
  let adding: Bool
  @State private var expanded = false

  var body: some View {
    DisclosureGroup(isExpanded: $expanded) {
      VStack(alignment: .leading, spacing: 4) {
        ForEach(tweak.changes.indices, id: \.self) { i in
          Text(tweak.changes[i].command)
            .font(.caption.monospaced())
            .foregroundStyle(.secondary)
            .textSelection(.enabled)
        }
      }
      .padding(.vertical, 4)
    } label: {
      HStack {
        Image(systemName: adding ? "plus.circle.fill" : "arrow.uturn.backward.circle.fill")
          .foregroundStyle(adding ? Color.accentColor : .orange)
        Text(tweak.title)
        if tweak.inProfile {
          Image(systemName: "lock.fill").font(.caption).foregroundStyle(.secondary)
            .help("由 RemoveMacAI 描述文件锁定")
        }
      }
    }
  }
}

// MARK: - Running

struct RunSheet: View {
  @Environment(AppModel.self) private var model

  var body: some View {
    VStack(spacing: 18) {
      switch model.run {
      case .working(let text)?:
        ProgressView().controlSize(.large)
        Text(text).font(.headline)
      case .approveProfile(let remove)?:
        Image(systemName: "checkmark.shield").font(.system(size: 44)).foregroundStyle(.tint)
        Text(remove ? "在“系统设置”中移除描述文件" : "在“系统设置”中批准描述文件")
          .font(.title3.weight(.semibold))
        VStack(alignment: .leading, spacing: 8) {
          if remove {
            step(1, "在“设备管理”中选择 RemoveMacAI。")
            step(2, "点击减号或“移除”，然后输入密码。")
          } else {
            step(1, "在“已下载”区域中双击 RemoveMacAI。")
            step(2, "点击“安装”，然后输入密码。")
          }
        }
        .frame(maxWidth: 360, alignment: .leading)
        HStack(spacing: 8) {
          ProgressView().controlSize(.small)
          Text("正在等待系统设置确认…").foregroundStyle(.secondary)
        }
        Text("如果“系统设置”提示无法安装描述文件，请点击“取消”，并在 GitHub 报告问题。")
          .font(.caption).foregroundStyle(.tertiary).multilineTextAlignment(.center).frame(maxWidth: 340)
        HStack {
          Button("取消") { model.cancel() }
          Button("打开系统设置") { Commands.openProfileSettings() }
            .buttonStyle(.borderedProminent)
        }
      case .finished(let problems, let freed)?:
        Image(systemName: problems.isEmpty ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
          .font(.system(size: 44))
          .foregroundStyle(problems.isEmpty ? Color.green : Color.orange)
        Text(problems.isEmpty ? "完成" : "已完成，但存在问题").font(.title3.weight(.semibold))
        if let freed, freed > 0 {
          Text("已删除 \(Term.size(freed)) 的模型。macOS 会自行安排文件清理，因此“储存空间”可能暂时仍将其计入占用。")
            .multilineTextAlignment(.center).foregroundStyle(.secondary).frame(maxWidth: 380)
        }
        if !problems.isEmpty {
          ScrollView {
            VStack(alignment: .leading, spacing: 6) {
              ForEach(problems, id: \.self) { Text("• " + $0).textSelection(.enabled) }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          }
          .frame(maxWidth: 420, maxHeight: 160)
        }
        Button("完成") { model.dismissRun() }
          .buttonStyle(.borderedProminent)
          .keyboardShortcut(.defaultAction)
      case nil:
        EmptyView()
      }
    }
    .padding(28)
    .frame(width: 460)
    .interactiveDismissDisabled()
  }

  func step(_ n: Int, _ text: String) -> some View {
    HStack(alignment: .firstTextBaseline, spacing: 10) {
      Text("\(n)").font(.callout.weight(.semibold).monospacedDigit())
        .frame(width: 22, height: 22)
        .background(Circle().fill(.quaternary))
      Text(text)
    }
  }
}
