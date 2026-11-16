import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "GHaptics") {
      HapticsChannel.register(messenger: registrar.messenger())
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
