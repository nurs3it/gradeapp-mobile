import SwiftUI

/// «Веер» tokens, mirrored from lib/ui/tokens/colors.dart (the source of
/// truth). Change both together. Hex lives only here and in colors.dart.
enum G {
  static func color(_ light: UInt32, _ dark: UInt32) -> Color {
    Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light) })
  }

  static let canvas = color(0xF2F4F8, 0x090C12)
  static let surface = color(0xFFFFFF, 0x131821)
  static let surface2 = color(0xEAEEF4, 0x1B212C)
  static let hairline = color(0xE3E7EE, 0x232A36)
  static let ink = color(0x0D1320, 0xF2F5FA)
  static let ink2 = color(0x4A5466, 0xA3ADBE)
  static let ink3 = color(0x5D6779, 0x8B96A8)
  static let primarySoft = color(0xE6EFFD, 0x132545)
  static let warn = color(0x975400, 0xFFB547)
  static let brand = Color(UIColor(hex: 0x0A5BD8))
  static let onFill = Color.white
  /// Brand blue readable on the dark Live Activity surface.
  static let toastAction = Color(UIColor(hex: 0x7AABFF))

  struct Subject {
    let fill: UInt32
    let tintLight: UInt32
    let tintDark: UInt32
    let markerDark: UInt32
  }

  /// Order matches `gSubjects` in colors.dart.
  static let subjects: [Subject] = [
    Subject(fill: 0x4F46E5, tintLight: 0xEAE9FC, tintDark: 0x242558, markerDark: 0x9A94FF),
    Subject(fill: 0x0B6F43, tintLight: 0xE2EEE8, tintDark: 0x11302B, markerDark: 0x5BD69A),
    Subject(fill: 0xAE3A0B, tintLight: 0xF5E7E2, tintDark: 0x3E221B, markerDark: 0xFF8F5E),
    Subject(fill: 0x6D35DB, tintLight: 0xEDE7FB, tintDark: 0x2C2055, markerDark: 0xB38CFF),
    Subject(fill: 0xA61F84, tintLight: 0xF4E4F0, tintDark: 0x3C1A3D, markerDark: 0xF17ACF),
    Subject(fill: 0x0A6476, tintLight: 0xE2ECEF, tintDark: 0x102D39, markerDark: 0x4FC6DB),
    Subject(fill: 0x875500, tintLight: 0xF1EBE0, tintDark: 0x332918, markerDark: 0xF2B33D),
    Subject(fill: 0xB41F48, tintLight: 0xF6E4E9, tintDark: 0x401A2C, markerDark: 0xFF7E9F),
  ]

  static func subject(_ i: Int) -> Subject { subjects[((i % subjects.count) + subjects.count) % subjects.count] }
  static func fill(_ i: Int) -> Color { Color(UIColor(hex: subject(i).fill)) }
  static func marker(_ i: Int) -> Color { color(subject(i).fill, subject(i).markerDark) }
  static func tint(_ i: Int) -> Color { color(subject(i).tintLight, subject(i).tintDark) }

  /// Onest ships inside the extension (UIAppFonts); falls back to the system
  /// font if the file is missing.
  static func font(_ size: CGFloat, _ weight: Weight = .semibold) -> Font {
    .custom(weight.rawValue, size: size)
  }

  enum Weight: String {
    case regular = "Onest-Regular"
    case semibold = "Onest-SemiBold"
    case bold = "Onest-Bold"
    case heavy = "Onest-ExtraBold"
  }
}

extension UIColor {
  convenience init(hex: UInt32) {
    self.init(
      red: CGFloat((hex >> 16) & 0xFF) / 255,
      green: CGFloat((hex >> 8) & 0xFF) / 255,
      blue: CGFloat(hex & 0xFF) / 255,
      alpha: 1
    )
  }
}

/// Gallery strings: ru / kk / en by the phone's language.
func tr(_ ru: String, _ kk: String, _ en: String) -> LocalizedStringKey {
  let lang = Locale.preferredLanguages.first?.prefix(2) ?? "ru"
  return LocalizedStringKey(lang == "kk" ? kk : lang == "en" ? en : ru)
}
