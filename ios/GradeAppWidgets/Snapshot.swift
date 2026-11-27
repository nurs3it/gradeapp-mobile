import Foundation
import WidgetKit

/// What the app wrote for the widgets (lib/features/platform/widget_snapshot.dart,
/// schema v2 — v1 plus `children`; a v1 file decodes with `children == nil`).
/// Everything is decided there; this file only reads it and
/// answers «what is on at time T» — it never invents a lesson.
struct Snapshot: Decodable {
  struct Lesson: Decodable, Hashable {
    let id: String
    let subject: String
    let start: String
    let end: String
    let room: String
    let cls: String
    let ci: Int
  }

  struct Day: Decodable {
    let date: String
    let lessons: [Lesson]
  }

  struct Hw: Decodable {
    struct Item: Decodable, Hashable { let course: String; let title: String }
    let date: String
    let minutes: Int
    let items: [Item]
  }

  /// W3 «Статус ребёнка»: status text and counts, never a grade value.
  struct Child: Decodable, Hashable {
    let id: String
    let name: String
    let cls: String
    let kind: String
    let text: String
    let newGrades: Int
    let gradesText: String
  }

  let v: Int
  let role: String
  let who: String
  let lang: String
  let generatedAt: String
  let generatedLabel: String
  let labels: [String: String]
  let days: [Day]
  let homework: Hw
  let children: [Child]?

  /// The first child (the app puts the selected one first), if any.
  var firstChild: Child? { children?.first }
  var isParent: Bool { role == "parent" }

  func childURL(_ c: Child?) -> URL {
    URL(string: c.map { "gradeapp://app/p/today?child=\($0.id)" } ?? "gradeapp://app/p/today")!
  }

  func label(_ k: String) -> String { labels[k] ?? "" }

  var generated: Date? { Snapshot.iso.date(from: generatedAt) ?? Snapshot.isoFraction.date(from: generatedAt) }
  var isTeacher: Bool { role == "teacher" }
  var signedOut: Bool { role == "none" }

  private static let iso: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime]
    return f
  }()

  private static let isoFraction: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return f
  }()

  static let appGroup = "group.kz.gradeapp.gradeapp"

  static func load() -> Snapshot? {
    guard let raw = UserDefaults(suiteName: appGroup)?.string(forKey: "snapshot"),
      let data = raw.data(using: .utf8)
    else { return nil }
    return try? JSONDecoder().decode(Snapshot.self, from: data)
  }

  /// A lesson with its absolute times.
  struct Slot: Hashable {
    let lesson: Lesson
    let date: String
    let starts: Date
    let ends: Date
  }

  private static let cal = Calendar.current
  private static let day: DateFormatter = {
    let f = DateFormatter()
    f.calendar = Calendar(identifier: .gregorian)
    f.locale = Locale(identifier: "en_US_POSIX")
    f.dateFormat = "yyyy-MM-dd HH:mm"
    return f
  }()

  var slots: [Slot] {
    days.flatMap { d in
      d.lessons.compactMap { l -> Slot? in
        guard let s = Snapshot.day.date(from: "\(d.date) \(l.start)"), let e = Snapshot.day.date(from: "\(d.date) \(l.end)")
        else { return nil }
        return Slot(lesson: l, date: d.date, starts: s, ends: e)
      }
    }.sorted { $0.starts < $1.starts }
  }

  /// Stale: the data is older than a day (spec W1). Then no lesson is shown.
  func isStale(at t: Date) -> Bool {
    guard let g = generated else { return true }
    return t.timeIntervalSince(g) > 24 * 3600
  }

  func current(at t: Date) -> Slot? { slots.first { $0.starts <= t && t < $0.ends } }
  func next(at t: Date) -> Slot? { slots.first { $0.starts > t } }

  /// Moments the picture changes: each bell, plus the stale boundary and the
  /// end of the data. The timeline holds one entry per moment, so the widget
  /// never needs a reload to stay right.
  func changePoints(from t: Date, horizon: TimeInterval = 36 * 3600) -> [Date] {
    var pts: Set<Date> = []
    for s in slots {
      pts.insert(s.starts)
      pts.insert(s.ends)
    }
    if let g = generated { pts.insert(g.addingTimeInterval(24 * 3600)) }
    return pts.filter { $0 > t && $0 < t.addingTimeInterval(horizon) }.sorted()
  }

  /// «Физика · 10:25» etc.
  func room(_ l: Lesson) -> String {
    l.room.isEmpty ? "" : label("roomFmt").replacingOccurrences(of: "%s", with: l.room)
  }

  func minutes(_ n: Int) -> String { label("minFmt").replacingOccurrences(of: "%s", with: "\(n)") }

  /// Where a tap on this lesson goes (gradeapp://app/... → go_router).
  func url(for l: Lesson?) -> URL {
    switch role {
    case "teacher":
      if let l = l { return URL(string: "gradeapp://app/lesson/\(l.id)")! }
      return URL(string: "gradeapp://app/t/today")!
    case "parent": return URL(string: "gradeapp://app/p/week")!
    default: return URL(string: "gradeapp://app/s/week")!
    }
  }

  var homeworkURL: URL {
    URL(string: role == "parent" ? "gradeapp://app/p/week" : "gradeapp://app/s/tasks")!
  }
}
