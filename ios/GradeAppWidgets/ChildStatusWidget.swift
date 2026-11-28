import SwiftUI
import WidgetKit

/// W3 «Статус ребёнка» (parent): where the child is and how many grades are
/// new, never which. Home screen (small) and lock screen (rectangular,
/// inline, circular) — the lock screen shows only the status.
///
/// WidgetKit here is a static configuration, so every instance shows the
/// first child (the one selected in the app). Choosing a child per widget
/// needs an AppIntent; Android has it through the configure activity.
struct ChildStatusWidget: Widget {
  let kind = "ChildStatusWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: ChildProvider()) { entry in
      ChildStatusView(entry: entry)
    }
    .configurationDisplayName(tr("Статус ребёнка", "Баланың күйі", "Child status"))
    .description(tr(
      "В школе или нет и сколько новых оценок (без самих оценок).",
      "Мектепте ме, жоқ па және жаңа бағалар саны (бағасыз).",
      "At school or not, and how many new grades (no marks)."
    ))
    .supportedFamilies([.systemSmall, .accessoryRectangular, .accessoryInline, .accessoryCircular])
  }
}

struct ChildEntry: TimelineEntry {
  let date: Date
  let snap: Snapshot?
}

struct ChildProvider: TimelineProvider {
  func placeholder(in context: Context) -> ChildEntry { ChildEntry(date: Date(), snap: ChildProvider.sample) }

  func getSnapshot(in context: Context, completion: @escaping (ChildEntry) -> Void) {
    completion(ChildEntry(date: Date(), snap: context.isPreview ? ChildProvider.sample : Snapshot.load()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<ChildEntry>) -> Void) {
    let snap = Snapshot.load()
    let now = Date()
    var entries = [ChildEntry(date: now, snap: snap)]
    // The picture changes by itself once: when the data turns a day old.
    if let g = snap?.generated, g.addingTimeInterval(24 * 3600) > now {
      entries.append(ChildEntry(date: g.addingTimeInterval(24 * 3600), snap: snap))
    }
    // …and when the last lesson ends («В школе» → «Уроки закончились»).
    if let u = snap?.firstChild?.untilDate, u > now {
      entries.append(ChildEntry(date: u, snap: snap))
      entries.sort { $0.date < $1.date }
    }
    // Reloaded when the app writes new data (silent push, app open).
    completion(Timeline(entries: entries, policy: .after(now.addingTimeInterval(3600))))
  }

  /// The gallery preview.
  static let sample: Snapshot? = {
    let json = """
      {"v":2,"role":"parent","who":"Дана","lang":"ru","generatedAt":"\(ISO8601DateFormatter().string(from: Date()))",
       "generatedLabel":"08:00","labels":{"updated":"Обновлено 08:00","stale":"Откройте приложение, чтобы обновить",
       "signedOut":"Войдите в GradeApp"},
       "days":[],"homework":{"date":"","minutes":0,"items":[]},
       "children":[{"id":"1","name":"Дана","cls":"3А","kind":"in","text":"В школе с 07:52","since":"07:52",
                    "newGrades":2,"gradesText":"2 новые оценки"}]}
      """
    return try? JSONDecoder().decode(Snapshot.self, from: Data(json.utf8))
  }()
}

struct ChildStatusView: View {
  @Environment(\.widgetFamily) var family
  let entry: ChildEntry

  private enum State {
    case signedOut
    case notParent
    case noChild
    case stale(Snapshot.Child)
    case child(Snapshot.Child)
  }

  private var state: State {
    guard let s = entry.snap, !s.signedOut else { return .signedOut }
    guard s.isParent else { return .notParent }
    guard let c = s.firstChild else { return .noChild }
    return s.isStale(at: entry.date) || c.kind == "unknown" ? .stale(c) : .child(c)
  }

  private func tint(_ kind: String) -> Color {
    switch kind {
    case "in": return G.ok
    case "absent": return G.bad
    case "notyet": return G.warn
    default: return G.ink
    }
  }

  private func symbol(_ kind: String) -> String {
    switch kind {
    case "in": return "checkmark.circle.fill"
    case "absent": return "xmark.circle.fill"
    case "notyet": return "clock.fill"
    default: return "moon.zzz.fill"
    }
  }

  var body: some View {
    switch family {
    case .accessoryInline: inline
    case .accessoryCircular: circular
    case .accessoryRectangular: rectangular
    default: small
    }
  }

  private var message: LocalizedStringKey? {
    switch state {
    case .notParent: return tr("Войдите как родитель", "Ата-ана ретінде кіріңіз", "Sign in as a parent")
    case .noChild: return tr("Откройте GradeApp", "GradeApp ашыңыз", "Open GradeApp")
    default: return nil
    }
  }

  // MARK: Home screen

  @ViewBuilder var small: some View {
    switch state {
    case .child(let c):
      VStack(alignment: .leading, spacing: 4) {
        Text([c.name, c.cls].filter { !$0.isEmpty }.joined(separator: " · "))
          .font(G.font(12, .bold)).foregroundStyle(G.ink2).lineLimit(1)
        HStack(alignment: .top, spacing: 6) {
          Image(systemName: symbol(c.kind)).font(.system(size: 18)).foregroundStyle(tint(c.kind)).widgetAccentable()
          Text(c.text(at: entry.date)).font(G.font(18, .heavy)).foregroundStyle(tint(c.kind))
            .lineLimit(3).minimumScaleFactor(0.7)
        }
        Spacer(minLength: 0)
        Text(c.gradesText).font(G.font(13, .semibold)).foregroundStyle(G.ink2).lineLimit(2)
        if let s = entry.snap { UpdatedLine(snap: s) }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
      .widgetBackground(G.surface)
      .widgetURL(entry.snap!.childURL(c))
      .accessibilityElement(children: .ignore)
      .accessibilityLabel("\(c.name), \(c.text(at: entry.date)), \(c.gradesText)")
    case .stale(let c):
      VStack(alignment: .leading, spacing: 4) {
        Text(c.name).font(G.font(12, .bold)).foregroundStyle(G.ink2).lineLimit(1)
        Spacer(minLength: 0)
        Text(entry.snap?.label("stale") ?? "").font(G.font(15, .bold)).foregroundStyle(G.ink)
        if let s = entry.snap { UpdatedLine(snap: s) }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
      .widgetBackground(G.surface).widgetURL(entry.snap!.childURL(c))
    case .signedOut:
      EmptyState(title: entry.snap?.label("signedOut") ?? "GradeApp", snap: nil)
        .widgetBackground(G.surface).widgetURL(URL(string: "gradeapp://app/")!)
    default:
      VStack(alignment: .leading) {
        Spacer(minLength: 0)
        Text(message ?? "").font(G.font(15, .bold)).foregroundStyle(G.ink)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
      .widgetBackground(G.surface).widgetURL(URL(string: "gradeapp://app/")!)
    }
  }

  // MARK: Lock screen — the status only, never the grades.

  @ViewBuilder var rectangular: some View {
    switch state {
    case .child(let c):
      VStack(alignment: .leading, spacing: 1) {
        Text(c.name).font(.system(size: 15, weight: .heavy)).lineLimit(1).widgetAccentable()
        Text(c.text(at: entry.date)).font(.system(size: 13, weight: .semibold)).lineLimit(2)
        Text(entry.snap?.label("updated") ?? "").font(.system(size: 11)).foregroundStyle(.secondary).lineLimit(1)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .widgetURL(entry.snap!.childURL(c))
    case .stale: Text(entry.snap?.label("stale") ?? "").font(.system(size: 13, weight: .semibold))
    case .signedOut: Text(entry.snap?.label("signedOut") ?? "GradeApp").font(.system(size: 13, weight: .semibold))
    default: Text(message ?? "").font(.system(size: 13, weight: .semibold))
    }
  }

  @ViewBuilder var inline: some View {
    switch state {
    case .child(let c): Text("\(c.name): \(c.text(at: entry.date))")
    case .stale: Text(entry.snap?.label("stale") ?? "")
    case .signedOut: Text(entry.snap?.label("signedOut") ?? "GradeApp")
    default: Text(message ?? "")
    }
  }

  @ViewBuilder var circular: some View {
    ZStack {
      AccessoryWidgetBackground()
      switch state {
      case .child(let c):
        VStack(spacing: 0) {
          Image(systemName: symbol(c.kind)).font(.system(size: 18)).widgetAccentable()
          Text(String(c.name.prefix(5))).font(.system(size: 10, weight: .semibold)).lineLimit(1)
        }
      default:
        Image(systemName: "person.crop.circle")
      }
    }
  }
}
