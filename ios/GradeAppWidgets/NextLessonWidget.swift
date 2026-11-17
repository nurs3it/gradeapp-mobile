import SwiftUI
import WidgetKit

/// W1 «Следующий урок»: home screen (small) and lock screen
/// (rectangular, inline, circular).
struct NextLessonWidget: Widget {
  let kind = "NextLessonWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: LessonProvider()) { entry in
      NextLessonView(entry: entry)
    }
    .configurationDisplayName(tr("Следующий урок", "Келесі сабақ", "Next lesson"))
    .description(tr("Урок, кабинет и время до звонка.", "Сабақ, кабинет және қоңырауға дейінгі уақыт.", "The lesson, the room and time to the bell."))
    .supportedFamilies([.systemSmall, .accessoryRectangular, .accessoryInline, .accessoryCircular])
  }
}

struct NextLessonView: View {
  @Environment(\.widgetFamily) var family
  let entry: LessonEntry

  var body: some View {
    let p = phase(entry.snap, at: entry.date)
    switch family {
    case .accessoryInline: inline(p)
    case .accessoryCircular: circular(p)
    case .accessoryRectangular: rectangular(p)
    default: small(p)
    }
  }

  // MARK: Home screen

  @ViewBuilder func small(_ p: Phase) -> some View {
    switch p {
    case .running(let s), .upcoming(let s):
      let running: Bool = { if case .running = p { return true } else { return false } }()
      let snap = entry.snap!
      let l = s.lesson
      VStack(alignment: .leading, spacing: 2) {
        Text("\(running ? snap.label("now") : snap.label("nextShort")) · \(l.start)".uppercased())
          .font(G.font(11, .bold)).foregroundStyle(G.onFill.opacity(0.85)).lineLimit(1)
          .widgetAccentable()
        if snap.isTeacher && !l.cls.isEmpty {
          Text(l.cls).font(G.font(30, .heavy)).foregroundStyle(G.onFill).lineLimit(1).minimumScaleFactor(0.6)
          Text(l.subject)
            .font(G.font(14, .semibold)).foregroundStyle(G.onFill.opacity(0.9)).lineLimit(1)
          Text(snap.room(l)).font(G.font(13, .semibold)).foregroundStyle(G.onFill.opacity(0.9))
        } else {
          Text(l.subject).font(G.font(22, .heavy)).foregroundStyle(G.onFill).lineLimit(2).minimumScaleFactor(0.7)
          Text(snap.room(l)).font(G.font(14, .semibold)).foregroundStyle(G.onFill.opacity(0.9))
        }
        Spacer(minLength: 0)
        HStack(alignment: .firstTextBaseline, spacing: 4) {
          Text(running ? s.ends : s.starts, style: .timer)
            .font(G.font(running ? 30 : 26, .heavy)).foregroundStyle(G.onFill)
            .monospacedDigit().lineLimit(1).minimumScaleFactor(0.6)
            .widgetAccentable()
        }
        Text(running ? snap.label("endsIn") : snap.label("startsIn"))
          .font(G.font(11, .semibold)).foregroundStyle(G.onFill.opacity(0.85))
        UpdatedLine(snap: snap, color: G.onFill.opacity(0.75))
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
      .widgetBackground(G.fill(l.ci))
      .widgetURL(snap.url(for: l))
    case .stale:
      EmptyState(title: entry.snap?.label("stale") ?? "", snap: entry.snap)
        .widgetBackground(G.surface).widgetURL(URL(string: "gradeapp://app/")!)
    case .signedOut:
      EmptyState(title: entry.snap?.label("signedOut") ?? "GradeApp", snap: nil)
        .widgetBackground(G.surface).widgetURL(URL(string: "gradeapp://app/")!)
    case .none:
      EmptyState(title: entry.snap?.label("noMore") ?? "", snap: entry.snap)
        .widgetBackground(G.surface).widgetURL(URL(string: "gradeapp://app/")!)
    }
  }

  // MARK: Lock screen

  @ViewBuilder func rectangular(_ p: Phase) -> some View {
    switch p {
    case .running(let s), .upcoming(let s):
      let snap = entry.snap!
      let running: Bool = { if case .running = p { return true } else { return false } }()
      VStack(alignment: .leading, spacing: 1) {
        Text(snap.isTeacher && !s.lesson.cls.isEmpty ? "\(s.lesson.cls) · \(s.lesson.start)" : "\(s.lesson.subject) · \(s.lesson.start)")
          .font(.system(size: 15, weight: .heavy)).lineLimit(1).widgetAccentable()
        Text([snap.isTeacher ? s.lesson.subject : "", snap.room(s.lesson)].filter { !$0.isEmpty }.joined(separator: " · "))
          .font(.system(size: 12, weight: .semibold)).lineLimit(1)
        Text(running ? s.ends : s.starts, style: .timer).font(.system(size: 12, weight: .semibold)).monospacedDigit()
        Text(snap.label("updated")).font(.system(size: 11)).foregroundStyle(.secondary).lineLimit(1)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .widgetURL(snap.url(for: s.lesson))
    case .stale:
      Text(entry.snap?.label("stale") ?? "").font(.system(size: 13, weight: .semibold))
    case .signedOut:
      Text(entry.snap?.label("signedOut") ?? "GradeApp").font(.system(size: 13, weight: .semibold))
    case .none:
      VStack(alignment: .leading) {
        Text(entry.snap?.label("noMore") ?? "").font(.system(size: 13, weight: .semibold))
        Text(entry.snap?.label("updated") ?? "").font(.system(size: 11)).foregroundStyle(.secondary)
      }
    }
  }

  @ViewBuilder func inline(_ p: Phase) -> some View {
    switch p {
    case .running(let s), .upcoming(let s):
      let snap = entry.snap!
      let name = snap.isTeacher && !s.lesson.cls.isEmpty ? s.lesson.cls : s.lesson.subject
      Text("\(name) \(s.lesson.start)\(s.lesson.room.isEmpty ? "" : " · \(s.lesson.room)")")
    case .stale: Text(entry.snap?.label("stale") ?? "")
    case .signedOut: Text(entry.snap?.label("signedOut") ?? "GradeApp")
    case .none: Text(entry.snap?.label("noMore") ?? "")
    }
  }

  @ViewBuilder func circular(_ p: Phase) -> some View {
    switch p {
    case .running(let s):
      ProgressView(timerInterval: s.starts...s.ends, countsDown: true, label: { EmptyView() }, currentValueLabel: {
        Text(s.ends, style: .timer).monospacedDigit().font(.system(size: 11, weight: .bold)).minimumScaleFactor(0.5)
      }).progressViewStyle(.circular)
    case .upcoming(let s):
      ZStack {
        AccessoryWidgetBackground()
        VStack(spacing: 0) {
          Text(s.lesson.start).font(.system(size: 15, weight: .heavy)).widgetAccentable()
          Text(String(s.lesson.subject.prefix(4))).font(.system(size: 11, weight: .semibold))
        }
      }
    default:
      ZStack { AccessoryWidgetBackground(); Image(systemName: "calendar") }
    }
  }
}
