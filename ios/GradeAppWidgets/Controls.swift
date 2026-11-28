import AppIntents
import SwiftUI
import WidgetKit

/// W7 Controls (Control Center, Lock Screen, Action button): one tap opens the
/// app on a role-neutral link; the Flutter router picks the screen for the
/// signed-in role (lib/app/router.dart, shortcutRoute).
@available(iOS 18.0, *)
private func trs(_ ru: String, _ kk: String, _ en: String) -> String {
  let lang = Locale.preferredLanguages.first?.prefix(2) ?? "ru"
  return lang == "kk" ? kk : lang == "en" ? en : ru
}

@available(iOS 18.0, *)
struct TodayControl: ControlWidget {
  var body: some ControlWidgetConfiguration {
    StaticControlConfiguration(kind: "kz.gradeapp.gradeapp.control.today") {
      ControlWidgetButton(action: OpenTodayControlIntent()) {
        Label(trs("Сегодня", "Бүгін", "Today"), systemImage: "sun.max")
      }
    }
    .displayName(LocalizedStringResource(stringLiteral: trs("GradeApp: сегодня", "GradeApp: бүгін", "GradeApp: today")))
  }
}

@available(iOS 18.0, *)
struct CheckInControl: ControlWidget {
  var body: some ControlWidgetConfiguration {
    StaticControlConfiguration(kind: "kz.gradeapp.gradeapp.control.checkin") {
      ControlWidgetButton(action: CheckInControlIntent()) {
        Label(trs("Я в школе", "Мен мектептемін", "I'm at school"), systemImage: "person.crop.square.badge.camera")
      }
    }
    .displayName(LocalizedStringResource(stringLiteral: trs("GradeApp: отметиться", "GradeApp: белгілену", "GradeApp: check in")))
  }
}
