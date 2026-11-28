import ActivityKit
import Foundation

/// W6 «Мой учебный день»: the student's Live Activity. Started by the app or
/// by the server (push-to-start), then updated by the server at each bell
/// (backend B6, `send_live_activity_updates`). The content state is the B6
/// contract: Unix seconds, no grades, no surname.
@available(iOS 16.2, *)
struct DayActivityAttributes: ActivityAttributes {
  struct ContentState: Codable, Hashable {
    /// before | lesson | break | done
    var phase: String
    /// The current lesson (phase lesson) or the next one (before, break).
    var subject: String
    var room: String
    var startsAt: Int
    var endsAt: Int
    var nextSubject: String
    var nextStartsAt: Int?
    /// Lessons left today, the current one included.
    var left: Int

    var start: Date { Date(timeIntervalSince1970: TimeInterval(startsAt)) }
    var end: Date { Date(timeIntervalSince1970: TimeInterval(endsAt)) }
  }

  var studentName: String
}
