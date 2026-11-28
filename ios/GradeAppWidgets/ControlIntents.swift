import AppIntents
import Foundation

/// Intents behind the W7 Controls. Compiled into both the app and the widget
/// extension: with `openAppWhenRun` the system runs `perform()` in the app,
/// which opens the role-neutral link (lib/app/router.dart, shortcutRoute).
@available(iOS 18.0, *)
enum ControlLink {
  /// Set by the app at launch; never called in the extension.
  nonisolated(unsafe) static var open: (String) -> Void = { _ in }
}

@available(iOS 18.0, *)
struct OpenTodayControlIntent: AppIntent {
  static let title: LocalizedStringResource = "Today"
  static let isDiscoverable = false
  static let openAppWhenRun = true
  @MainActor func perform() async throws -> some IntentResult {
    ControlLink.open("today")
    return .result()
  }
}

@available(iOS 18.0, *)
struct CheckInControlIntent: AppIntent {
  static let title: LocalizedStringResource = "Check in"
  static let isDiscoverable = false
  static let openAppWhenRun = true
  @MainActor func perform() async throws -> some IntentResult {
    ControlLink.open("checkin")
    return .result()
  }
}
