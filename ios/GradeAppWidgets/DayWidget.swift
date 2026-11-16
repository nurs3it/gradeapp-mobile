import SwiftUI
import WidgetKit

/// W2 «День»: medium and large. Left (medium) the lesson on now or next,
/// right the lessons after it; at the bottom tomorrow's homework.
struct DayWidget: Widget {
  let kind = "DayWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: LessonProvider()) { entry in
      DayView(entry: entry)
    }
    .configurationDisplayName(tr("День", "Күн", "Day"))
    .description(tr("Уроки дня и домашнее задание на завтра.", "Күндегі сабақтар және ертеңгі үй тапсырмасы.", "Today's lessons and tomorrow's homework."))
    .supportedFamilies([.systemMedium, .systemLarge])
  }
}

struct DayView: View {
  @Environment(\.widgetFamily) var family
  let entry: LessonEntry

  private var dayString: String {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd"
    f.locale = Locale(identifier: "en_US_POSIX")
    return f.string(from: entry.date)
  }

  var body: some View {
    let p = phase(entry.snap, at: entry.date)
    switch p {
    case .signedOut:
      EmptyState(title: entry.snap?.label("signedOut") ?? "GradeApp", snap: nil)
        .widgetBackground(G.surface).widgetURL(URL(string: "gradeapp://app/")!)
    case .stale:
      EmptyState(title: entry.snap?.label("stale") ?? "", snap: entry.snap)
        .widgetBackground(G.surface).widgetURL(URL(string: "gradeapp://app/")!)
    case .running(let s), .upcoming(let s):
      content(snap: entry.snap!, hero: s, running: { if case .running = p { return true } else { return false } }())
    case .none:
      VStack(alignment: .leading, spacing: 8) {
        EmptyState(title: entry.snap?.label("noMore") ?? "", snap: entry.snap)
        if let snap = entry.snap { homework(snap) }
      }
      .widgetBackground(G.surface)
      .widgetURL(URL(string: "gradeapp://app/")!)
    }
  }

  @ViewBuilder func content(snap: Snapshot, hero: Snapshot.Slot, running: Bool) -> some View {
    let after = snap.slots.filter { $0.starts >= hero.ends }
    let rowsMax = family == .systemLarge ? 8 : 3
    let sameDay = snap.slots.filter { $0.date == hero.date }
    if family == .systemLarge {
      VStack(alignment: .leading, spacing: 10) {
        header(snap, hero: hero)
        VStack(spacing: 4) {
          ForEach(Array(sameDay.prefix(rowsMax)), id: \.self) { s in
            row(snap, s, dimmed: s.ends <= entry.date, highlighted: s == hero)
          }
        }
        Spacer(minLength: 0)
        homework(snap)
        UpdatedLine(snap: snap)
      }
      .widgetBackground(G.surface)
    } else {
      VStack(spacing: 6) {
        HStack(spacing: 12) {
          mini(snap, hero, running: running)
            .frame(width: 142)
          VStack(spacing: 2) {
            ForEach(Array(after.filter { $0.date == hero.date }.prefix(rowsMax)), id: \.self) { s in
              row(snap, s, dimmed: false, highlighted: false)
            }
            Spacer(minLength: 0)
          }
        }
        HStack {
          homework(snap)
          UpdatedLine(snap: snap)
        }
      }
      .widgetBackground(G.surface)
    }
  }

  func header(_ snap: Snapshot, hero: Snapshot.Slot) -> some View {
    HStack {
      Text(hero.date == dayString ? snap.label("day") : snap.label("tomorrow"))
        .font(G.font(20, .heavy)).foregroundStyle(G.ink).widgetAccentable()
      Spacer()
      if !snap.who.isEmpty { Text(snap.who).font(G.font(13, .semibold)).foregroundStyle(G.ink2) }
    }
  }

  /// The loud sheet in miniature: subject fill, white text, the countdown.
  func mini(_ snap: Snapshot, _ s: Snapshot.Slot, running: Bool) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(running ? snap.label("now").uppercased() : "\(snap.label("next").uppercased())")
        .font(G.font(11, .bold)).foregroundStyle(G.onFill.opacity(0.85)).lineLimit(1)
      Text(snap.isTeacher && !s.lesson.cls.isEmpty ? s.lesson.cls : s.lesson.subject)
        .font(G.font(20, .heavy)).foregroundStyle(G.onFill).lineLimit(2).minimumScaleFactor(0.7)
      Text(snap.room(s.lesson)).font(G.font(13, .semibold)).foregroundStyle(G.onFill.opacity(0.9))
      Spacer(minLength: 0)
      Text(running ? s.ends : s.starts, style: .timer)
        .font(G.font(24, .heavy)).foregroundStyle(G.onFill).monospacedDigit().minimumScaleFactor(0.6).lineLimit(1)
      ProgressView(timerInterval: s.starts...s.ends, countsDown: false, label: { EmptyView() }, currentValueLabel: { EmptyView() })
        .progressViewStyle(.linear).tint(G.onFill).opacity(running ? 1 : 0)
    }
    .padding(12)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(G.fill(s.lesson.ci)))
    .widgetURL(snap.url(for: s.lesson))
  }

  func row(_ snap: Snapshot, _ s: Snapshot.Slot, dimmed: Bool, highlighted: Bool) -> some View {
    Link(destination: snap.url(for: s.lesson)) {
      HStack(spacing: 8) {
        Text(s.lesson.start).font(G.font(13, .bold)).monospacedDigit().foregroundStyle(G.ink2).frame(width: 40, alignment: .leading)
        RoundedRectangle(cornerRadius: 2).fill(G.marker(s.lesson.ci)).frame(width: 4, height: 22)
        Text(snap.isTeacher && !s.lesson.cls.isEmpty ? "\(s.lesson.cls) · \(s.lesson.subject)" : s.lesson.subject)
          .font(G.font(14, .semibold)).foregroundStyle(G.ink).lineLimit(1)
        Spacer(minLength: 4)
        Text(snap.room(s.lesson)).font(G.font(12, .semibold)).foregroundStyle(G.ink3).lineLimit(1)
      }
      .padding(.vertical, 3).padding(.horizontal, highlighted ? 6 : 0)
      .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(highlighted ? G.tint(s.lesson.ci) : Color.clear))
      .opacity(dimmed ? 0.5 : 1)
    }
  }

  /// Plate «ДЗ на завтра · 3 · ≈ 70 мин» (students and parents).
  @ViewBuilder func homework(_ snap: Snapshot) -> some View {
    if !snap.isTeacher {
      let n = snap.homework.items.count
      Link(destination: snap.homeworkURL) {
        HStack(spacing: 6) {
          Text(n == 0 ? snap.label("noHomework") : "\(snap.label("homework")) · \(n)\(snap.homework.minutes > 0 ? " · ≈ \(snap.minutes(snap.homework.minutes))" : "")")
            .font(G.font(12, .bold)).foregroundStyle(G.ink).lineLimit(1).minimumScaleFactor(0.8)
        }
        .padding(.vertical, 6).padding(.horizontal, 10)
        .background(Capsule().fill(G.surface2))
      }
    }
  }
}
