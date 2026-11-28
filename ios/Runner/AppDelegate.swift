import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Plugins register after launch with the implicit engine, so
    // firebase_messaging misses its chance to ask for the APNs token itself.
    application.registerForRemoteNotifications()
    if #available(iOS 18.0, *) {
      // W7 Controls: their intents run here and open a role-neutral link.
      ControlLink.open = { target in
        if let url = URL(string: "gradeapp://app/go/\(target)") { UIApplication.shared.open(url) }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    NSLog("GradeApp APNs registration failed: %@", error.localizedDescription)
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "GHaptics") {
      HapticsChannel.register(messenger: registrar.messenger())
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "GSystem") {
      SystemChannel.register(messenger: registrar.messenger())
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "GLiveActivity") {
      LiveActivityChannel.register(messenger: registrar.messenger())
    }
  }
}

/// Notification-style haptics (success / warning / error) that Flutter's
/// HapticFeedback does not expose. Dart side: lib/ui/haptics.dart.
enum HapticsChannel {
  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "kz.gradeapp/haptics", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard call.method == "notify", let kind = call.arguments as? String else {
        result(FlutterMethodNotImplemented)
        return
      }
      let type: UINotificationFeedbackGenerator.FeedbackType
      switch kind {
      case "error": type = .error
      case "warning": type = .warning
      default: type = .success
      }
      let generator = UINotificationFeedbackGenerator()
      generator.prepare()
      generator.notificationOccurred(type)
      result(nil)
    }
  }
}

/// App badge and the system settings page. Dart side:
/// lib/features/notifications/push.dart (SystemBridge).
enum SystemChannel {
  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "kz.gradeapp/system", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "setBadge":
        let count = call.arguments as? Int ?? 0
        if #available(iOS 16.0, *) {
          UNUserNotificationCenter.current().setBadgeCount(count)
        } else {
          UIApplication.shared.applicationIconBadgeNumber = count
        }
        result(nil)
      case "openSettings":
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url)
        }
        result(nil)
      case "createChannels":
        result(nil)  // Android only
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
