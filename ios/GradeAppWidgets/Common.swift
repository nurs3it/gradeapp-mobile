import SwiftUI
import WidgetKit

enum Phase {
  case signedOut
  case stale
  case running(Snapshot.Slot)
  case upcoming(Snapshot.Slot)
  case none
}

func phase(_ snap: Snapshot?, at t: Date) -> Phase {
  guard let s = snap, !s.signedOut else { return .signedOut }
  // Data older than a day is never shown as if it were current.
  if s.isStale(at: t) { return .stale }
  if let c = s.current(at: t) { return .running(c) }
  if let n = s.next(at: t) { return .upcoming(n) }
  return .none
}

struct LessonEntry: TimelineEntry {
  let date: Date
  let snap: Snapshot?
}

/// One entry per change point (each bell), so the picture is right all day
/// without reloads; the OS ticks the countdown (`Text(_, style: .timer)`).
struct LessonProvider: TimelineProvider {
  func placeholder(in context: Context) -> LessonEntry { LessonEntry(date: Date(), snap: LessonProvider.sample) }

  func getSnapshot(in context: Context, completion: @escaping (LessonEntry) -> Void) {
    completion(LessonEntry(date: Date(), snap: context.isPreview ? LessonProvider.sample : Snapshot.load()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<LessonEntry>) -> Void) {
    let snap = Snapshot.load()
    let now = Date()
    var entries = [LessonEntry(date: now, snap: snap)]
    if let s = snap {
      entries += s.changePoints(from: now).prefix(40).map { LessonEntry(date: $0, snap: s) }
    }
    // Reloaded when the app writes new data; the fallback is a gentle hourly look.
    completion(Timeline(entries: entries, policy: .after(now.addingTimeInterval(3600))))
  }

  /// The gallery preview.
  static let sample: Snapshot? = {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd"
    let today = f.string(from: Date())
    // A believable preview: the next lesson in 25 minutes (late evening keeps
    // the fixed times so the lessons stay on today's date).
    let hm = DateFormatter()
    hm.dateFormat = "HH:mm"
    let start = Date().addingTimeInterval(25 * 60)
    let fits = Calendar.current.isDateInToday(start.addingTimeInterval(105 * 60))
    let t = fits
      ? [start, start.addingTimeInterval(45 * 60), start.addingTimeInterval(55 * 60), start.addingTimeInterval(100 * 60)].map(hm.string)
      : ["23:00", "23:45", "23:50", "23:59"]
    let json = """
      {"v":1,"role":"student","who":"","lang":"ru","generatedAt":"\(ISO8601DateFormatter().string(from: Date()))",
       "generatedLabel":"08:00","labels":{"next":"Следующий урок","nextShort":"Дальше","now":"Сейчас","updated":"Обновлено 08:00",
       "roomFmt":"каб. %s","minFmt":"%s мин","homework":"ДЗ на завтра","startsIn":"Начнётся через","endsIn":"До конца",
       "stale":"Откройте приложение, чтобы обновить","noMore":"Сегодня уроков больше нет","tomorrow":"Завтра",
       "noHomework":"На завтра ничего не задано","signedOut":"Войдите в GradeApp","day":"День"},
       "days":[{"date":"\(today)","lessons":[
        {"id":"1","subject":"Алгебра","start":"\(t[0])","end":"\(t[1])","room":"312","cls":"","ci":0},
        {"id":"2","subject":"Физика","start":"\(t[2])","end":"\(t[3])","room":"204","cls":"","ci":5}]}],
       "homework":{"date":"","minutes":45,"items":[]}}
      """
    return try? JSONDecoder().decode(Snapshot.self, from: Data(json.utf8))
  }()
}

extension View {
  @ViewBuilder func widgetBackground(_ c: Color) -> some View {
    if #available(iOS 17.0, *) { containerBackground(c, for: .widget) } else { background(c) }
  }
}

func clock(_ d: Date) -> String {
  let f = DateFormatter()
  f.dateFormat = "HH:mm"
  return f.string(from: d)
}

/// «Обновлено 08:12» — always present, so a stale widget says so.
struct UpdatedLine: View {
  let snap: Snapshot
  var color: Color = G.ink3
  var body: some View {
    Text(snap.label("updated"))
      .font(G.font(11, .semibold))
      .foregroundStyle(color)
      .lineLimit(1)
  }
}

struct EmptyState: View {
  let title: String
  let snap: Snapshot?
  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Image(systemName: "rectangle.stack.fill").font(.system(size: 22)).foregroundStyle(G.brand)
      Spacer(minLength: 0)
      Text(title)
        .font(G.font(15, .bold))
        .foregroundStyle(G.ink)
        .minimumScaleFactor(0.8)
      if let s = snap, !s.signedOut { UpdatedLine(snap: s) }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
  }
}
