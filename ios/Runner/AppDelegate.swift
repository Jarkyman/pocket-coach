import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let themeChannel = FlutterMethodChannel(name: "com.hartvigsolutions.app/theme",
                                              binaryMessenger: controller.binaryMessenger)
    
    themeChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if (call.method == "setTheme") {
        if let args = call.arguments as? [String: Any],
           let theme = args["theme"] as? String {
          self.applyTheme(theme)
          result(nil)
        } else {
          result(FlutterError(code: "INVALID_ARGS", message: "Theme argument missing", details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func applyTheme(_ theme: String) {
    if #available(iOS 13.0, *) {
      let style: UIUserInterfaceStyle
      switch theme {
      case "dark":
        style = .dark
      case "light":
        style = .light
      default:
        style = .unspecified
      }
      
      // Apply to all windows
      if let window = self.window {
          window.overrideUserInterfaceStyle = style
      }
    }
  }
}
