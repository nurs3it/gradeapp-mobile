import ActivityKit
import Foundation

/// W5 «Идёт урок»: the Live Activity of the teacher's running lesson.
/// Compiled into the app (which starts and updates it, LiveActivity.swift)
/// and into the widget extension (which draws it). No student names, no
/// grades: class, subject, the bell, how many are marked. Text arrives
/// already localised from Dart (lib/features/platform/lesson_live.dart).
@available(iOS 16.2, *)
struct LessonActivityAttributes: ActivityAttributes {
  struct ContentState: Codable, Hashable {
    var title: String
    var subject: String
    var startsAt: Date
    var endsAt: Date
    var marked: Int
    var total: Int
    var ended: Bool
    var labelUntil: String
    var labelMarked: String
    var labelEnded: String
    /// Button text of «Все на месте» (W5); nil from an older app version.
    var labelAllPresent: String?
    /// After this the activity has nothing left to say (bell + 15 min).
    var endedUntil: Date
  }

  var lessonId: String
}
