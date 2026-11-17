import ActivityKit
import Flutter
import Foundation

/// Bridge for W5 «Идёт урок». Dart side: lib/features/platform/lesson_live.dart.
/// The activity is started, updated and ended by the app only (no push).
enum LiveActivityChannel {
  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "kz.gradeapp/live", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard #available(iOS 16.2, *) else {
        result(nil)
        return
      }
      let args = call.arguments as? [String: Any] ?? [:]
      switch call.method {
      case "start", "update":
        // `update` never brings back an activity the teacher swiped away.
        LiveActivityBridge.upsert(args, create: call.method == "start")
        result(nil)
      case "end":
        LiveActivityBridge.end(lessonId: args["lessonId"] as? String)
        result(nil)
      case "sweep":
        LiveActivityBridge.sweep()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}

@available(iOS 16.2, *)
enum LiveActivityBridge {
  private static func date(_ v: Any?) -> Date {
    Date(timeIntervalSince1970: ((v as? NSNumber)?.doubleValue ?? 0) / 1000)
  }

  private static func state(_ a: [String: Any]) -> LessonActivityAttributes.ContentState {
    LessonActivityAttributes.ContentState(
      title: a["title"] as? String ?? "",
      subject: a["subject"] as? String ?? "",
      startsAt: date(a["startsAt"]),
      endsAt: date(a["endsAt"]),
      marked: (a["marked"] as? NSNumber)?.intValue ?? 0,
      total: (a["total"] as? NSNumber)?.intValue ?? 0,
      ended: a["ended"] as? Bool ?? false,
      labelUntil: a["labelUntil"] as? String ?? "",
      labelMarked: a["labelMarked"] as? String ?? "",
      labelEnded: a["labelEnded"] as? String ?? "",
      labelAllPresent: a["labelAllPresent"] as? String,
      endedUntil: date(a["endedUntil"])
    )
  }

  /// The activity expires (goes stale) at the bell, then at bell + 15 min.
  private static func content(_ s: LessonActivityAttributes.ContentState) -> ActivityContent<LessonActivityAttributes.ContentState> {
    ActivityContent(state: s, staleDate: s.ended ? s.endedUntil : s.endsAt)
  }

  static func upsert(_ args: [String: Any], create: Bool) {
    guard let id = args["lessonId"] as? String else { return }
    let s = state(args)
    if let existing = Activity<LessonActivityAttributes>.activities.first(where: { $0.attributes.lessonId == id }) {
      Task { await existing.update(content(s)) }
      return
    }
    guard create, ActivityAuthorizationInfo().areActivitiesEnabled else { return }
    // One lesson at a time.
    end(lessonId: nil)
    do {
      _ = try Activity.request(attributes: LessonActivityAttributes(lessonId: id), content: content(s), pushType: nil)
    } catch {
      NSLog("GradeApp live activity: %@", error.localizedDescription)
    }
  }

  static func end(lessonId: String?) {
    for activity in Activity<LessonActivityAttributes>.activities
    where lessonId == nil || activity.attributes.lessonId == lessonId {
      Task { await activity.end(nil, dismissalPolicy: .immediate) }
    }
  }

  /// Ends what outlived its time: nothing may hang past bell + 15 min.
  static func sweep() {
    let now = Date()
    for activity in Activity<LessonActivityAttributes>.activities {
      let s = activity.content.state
      if now > s.endedUntil || now > s.endsAt.addingTimeInterval(30 * 60) {
        Task { await activity.end(nil, dismissalPolicy: .immediate) }
      }
    }
  }
}
