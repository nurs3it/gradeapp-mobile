import AppIntents
import UIKit

/// W7: Siri, Spotlight and the Shortcuts app. Each action opens one
/// role-neutral link (`gradeapp://app/go/<target>`); the Flutter router
/// resolves it for the signed-in role (lib/app/router.dart, shortcutRoute).
@available(iOS 17.0, *)
@MainActor
private func openApp(_ target: String) {
  if let url = URL(string: "gradeapp://app/go/\(target)") { UIApplication.shared.open(url) }
}

@available(iOS 17.0, *)
struct OpenTodayIntent: AppIntent {
  static let title: LocalizedStringResource = "Today"
  static let openAppWhenRun = true
  @MainActor func perform() async throws -> some IntentResult {
    openApp("today")
    return .result()
  }
}

@available(iOS 17.0, *)
struct OpenWeekIntent: AppIntent {
  static let title: LocalizedStringResource = "Schedule"
  static let openAppWhenRun = true
  @MainActor func perform() async throws -> some IntentResult {
    openApp("week")
    return .result()
  }
}

@available(iOS 17.0, *)
struct OpenGradesIntent: AppIntent {
  static let title: LocalizedStringResource = "Grades"
  static let openAppWhenRun = true
  @MainActor func perform() async throws -> some IntentResult {
    openApp("grades")
    return .result()
  }
}

@available(iOS 17.0, *)
struct CheckInIntent: AppIntent {
  static let title: LocalizedStringResource = "Check in at school"
  static let openAppWhenRun = true
  @MainActor func perform() async throws -> some IntentResult {
    openApp("checkin")
    return .result()
  }
}

@available(iOS 17.0, *)
struct OpenChatIntent: AppIntent {
  static let title: LocalizedStringResource = "Messages"
  static let openAppWhenRun = true
  @MainActor func perform() async throws -> some IntentResult {
    openApp("chat")
    return .result()
  }
}

@available(iOS 17.0, *)
struct GradeAppShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: OpenTodayIntent(),
      phrases: ["What's today in \(.applicationName)", "Open today in \(.applicationName)"],
      shortTitle: "Today",
      systemImageName: "sun.max"
    )
    AppShortcut(
      intent: OpenWeekIntent(),
      phrases: ["Show my schedule in \(.applicationName)", "\(.applicationName) schedule"],
      shortTitle: "Schedule",
      systemImageName: "calendar"
    )
    AppShortcut(
      intent: OpenGradesIntent(),
      phrases: ["Show grades in \(.applicationName)", "\(.applicationName) grades"],
      shortTitle: "Grades",
      systemImageName: "chart.line.uptrend.xyaxis"
    )
    AppShortcut(
      intent: CheckInIntent(),
      phrases: ["Check in with \(.applicationName)", "I'm at school in \(.applicationName)"],
      shortTitle: "Check in",
      systemImageName: "person.crop.square.badge.camera"
    )
    AppShortcut(
      intent: OpenChatIntent(),
      phrases: ["Open messages in \(.applicationName)", "\(.applicationName) messages"],
      shortTitle: "Messages",
      systemImageName: "bubble.left.and.bubble.right"
    )
  }
}
