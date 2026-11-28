import ActivityKit
import Flutter
import Foundation

/// Bridge for W5 «Идёт урок». Dart side: lib/features/platform/lesson_live.dart.
/// The activity is started, updated and ended by the app only (no push).
enum LiveActivityChannel {
  /// Kept to send push tokens back to Dart (W6).
  static var channel: FlutterMethodChannel?

  static func send(_ method: String, _ args: [String: Any]) {
    DispatchQueue.main.async { channel?.invokeMethod(method, arguments: args) }
  }

  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "kz.gradeapp/live", binaryMessenger: messenger)
    LiveActivityChannel.channel = channel
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
      case "dayStart", "dayUpdate":
        DayActivityBridge.upsert(args, create: call.method == "dayStart")
        result(nil)
      case "dayEnd":
        DayActivityBridge.end()
        result(nil)
      case "dayObserve":
        DayActivityBridge.observe()
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

/// W6 «Мой учебный день»: the app starts the activity (or the server does,
/// push-to-start); every activity's push token goes to Dart, which registers
/// it with the server (`/push/live-activity/`), and the server updates it at
/// each bell.
@available(iOS 16.2, *)
enum DayActivityBridge {
  private static var watched = Set<String>()
  private static var observing = false

  private static func state(_ a: [String: Any]) -> DayActivityAttributes.ContentState {
    func int(_ k: String) -> Int { (a[k] as? NSNumber)?.intValue ?? 0 }
    return DayActivityAttributes.ContentState(
      phase: a["phase"] as? String ?? "before",
      subject: a["subject"] as? String ?? "",
      room: a["room"] as? String ?? "",
      startsAt: int("startsAt"),
      endsAt: int("endsAt"),
      nextSubject: a["nextSubject"] as? String ?? "",
      nextStartsAt: (a["nextStartsAt"] as? NSNumber)?.intValue,
      left: int("left")
    )
  }

  private static func content(_ s: DayActivityAttributes.ContentState) -> ActivityContent<DayActivityAttributes.ContentState> {
    let boundary = s.phase == "lesson" ? s.endsAt : s.startsAt
    return ActivityContent(state: s, staleDate: Date(timeIntervalSince1970: TimeInterval(boundary + 60)))
  }

  static func upsert(_ args: [String: Any], create: Bool) {
    let s = state(args["state"] as? [String: Any] ?? [:])
    if let existing = Activity<DayActivityAttributes>.activities.first {
      if s.phase == "done" {
        Task { await existing.end(content(s), dismissalPolicy: .after(Date().addingTimeInterval(15 * 60))) }
      } else {
        Task { await existing.update(content(s)) }
      }
      return
    }
    guard create, s.phase != "done", ActivityAuthorizationInfo().areActivitiesEnabled else { return }
    do {
      let activity = try Activity.request(
        attributes: DayActivityAttributes(studentName: args["name"] as? String ?? ""),
        content: content(s),
        pushType: .token
      )
      watch(activity)
    } catch {
      NSLog("GradeApp day activity: %@", error.localizedDescription)
    }
  }

  static func end() {
    for activity in Activity<DayActivityAttributes>.activities {
      Task { await activity.end(nil, dismissalPolicy: .immediate) }
    }
  }

  /// Forwards the update token of an activity (ours or server-started).
  private static func watch(_ activity: Activity<DayActivityAttributes>) {
    guard watched.insert(activity.id).inserted else { return }
    Task {
      for await data in activity.pushTokenUpdates {
        LiveActivityChannel.send("dayToken", ["token": hex(data), "activityId": activity.id])
      }
    }
  }

  /// At launch: the push-to-start token (iOS 17.2+) and activities the
  /// server started while the app was closed.
  static func observe() {
    for activity in Activity<DayActivityAttributes>.activities { watch(activity) }
    guard !observing else { return }
    observing = true
    Task {
      for await activity in Activity<DayActivityAttributes>.activityUpdates { watch(activity) }
    }
    if #available(iOS 17.2, *) {
      Task {
        for await data in Activity<DayActivityAttributes>.pushToStartTokenUpdates {
          LiveActivityChannel.send("dayStartToken", ["token": hex(data)])
        }
      }
    }
  }

  private static func hex(_ d: Data) -> String { d.map { String(format: "%02x", $0) }.joined() }
}
