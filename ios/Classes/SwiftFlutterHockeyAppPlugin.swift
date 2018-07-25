import Flutter
import UIKit

public class SwiftFlutterHockeyAppPlugin: NSObject, FlutterPlugin {
	public static func register(with registrar: FlutterPluginRegistrar) {
		let channel = FlutterMethodChannel(name: "flutter_hockey_app", binaryMessenger: registrar.messenger())
		let instance = SwiftFlutterHockeyAppPlugin()
		registrar.addMethodCallDelegate(instance, channel: channel)

	}

	public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
		var arguments = call.arguments as! Dictionary<String, Any>
		switch call.method {
		case "init":
			initHockeyApp(appId: arguments["appId"] as! String, updateEnabled: arguments["updateEnabled"] as! Bool)
			result(nil)
			break;
		case "captureException":
			captureException()
			result(nil)
			break;
		default:
			result(nil)
		}
	}

	private func initHockeyApp(appId: String, updateEnabled: Bool) {

	}

	private func captureException() {

	}
}
