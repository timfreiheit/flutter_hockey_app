import Flutter
import UIKit
import HockeySDK

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
			captureException(exception: arguments["exception"] as! Dictionary<String, String>, stacktrace: arguments["stacktrace"] as! String)
			result(nil)
			break;
		default:
			result(nil)
		}
	}

	private func initHockeyApp(appId: String, updateEnabled: Bool) {
		BITHockeyManager.shared().configure(withIdentifier: appId)
		BITHockeyManager.shared().isUpdateManagerDisabled = !updateEnabled
		BITHockeyManager.shared().start()
		BITHockeyManager.shared().authenticator.authenticateInstallation()
		BITHockeyManager.shared().crashManager.crashManagerStatus = .autoSend
	}

	private func captureException(exception: Dictionary<String, String>, stacktrace: String) {
		let type = exception["type"] ?? "UNKNOWN"
		let message = exception["message"] ?? "UNKNOWN"

		createCrashReport(type: "123456", report:  "--\(type): \(message)--\n\(stacktrace)")
	}

	func bit_settingsDir() -> String? {
		var settingsDir: String? = nil
		var predSettingsDir: Int = 0
		if (predSettingsDir == 0) {
			let fileManager = FileManager()
			// temporary directory for crashes grabbed from PLCrashReporter
			let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
			settingsDir = URL(fileURLWithPath: paths[0]).appendingPathComponent("net.hockeyapp.sdk.ios").absoluteString
			if !(fileManager.fileExists(atPath: settingsDir ?? "")) {
				let attributes = [FileAttributeKey.posixPermissions : Int(truncating: 0o755)]
				try? fileManager.createDirectory(atPath: settingsDir ?? "", withIntermediateDirectories: true, attributes: attributes)
			}
		}
		predSettingsDir = 1
		return settingsDir
	}

	func getDevicePlatform() -> String {
		var size = 0
		sysctlbyname("hw.machine", nil, &size, nil, 0)
		var machine = [CChar](repeating: 0,  count: size)
		sysctlbyname("hw.machine", &machine, &size, nil, 0)
		return String(cString: machine)
	}

	func osBuild() -> String {
		var size = 0
		sysctlbyname("kern.osversion", nil, &size, nil, 0)
		var machine = [CChar](repeating: 0,  count: size)
		sysctlbyname("kern.osversion", &machine, &size, nil, 0)
		return String(cString: machine)
	}

	func getAppVersion() -> String? {
		return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
	}

	func getUserId() -> String {
		var userId = UserDefaults.standard.string(forKey: "HOCKEY_USER_ID")
		if let userId = userId {
			return userId
		}
		userId = NSUUID().uuidString
		UserDefaults.standard.set(userId, forKey: "HOCKEY_USER_ID")
		return userId!
	}

	func createCrashReport(type: String, report: String) {

		let fakeReportUUID = NSUUID().uuidString
		let fakeReporterKey = /*bit_appAnonID(false) ?? */"???"
		let fakeReportAppMarketingVersion = UserDefaults.standard.object(forKey: "BITAppMarketingVersion") as? String
		let fakeReportAppVersion = (UserDefaults.standard.object(forKey: "BITAppVersion") as? String) ?? getAppVersion() ?? "UNKNOWN"
		let fakeReportOSVersion = UserDefaults.standard.object(forKey: "BITAppOSVersion") ?? UIDevice.current.systemVersion
		var fakeReportOSVersionString = fakeReportOSVersion
		let fakeReportOSBuild = UserDefaults.standard.object(forKey: "BITAppOSBuild") ?? osBuild()
		fakeReportOSVersionString = "\(fakeReportOSVersion) (\(fakeReportOSBuild))"
		let fakeReportAppBundleIdentifier = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String
		let fakeReportDeviceModel = getDevicePlatform()
		let fakeReportAppUUIDs = UserDefaults.standard.object(forKey: "BITAppUUIDs") ?? ""
		var fakeReportString = ""
		fakeReportString += "Incident Identifier: \(fakeReportUUID)\n"
		fakeReportString += "CrashReporter Key:   \(fakeReporterKey)\n"
		fakeReportString += "Hardware Model:      \(fakeReportDeviceModel)\n"
		fakeReportString += "Identifier:      \(fakeReportAppBundleIdentifier ?? "")\n"
		let fakeReportAppVersionString = fakeReportAppMarketingVersion != nil ? "\(fakeReportAppMarketingVersion) (\(fakeReportAppVersion))" : fakeReportAppVersion

		fakeReportString += "Version:         \(fakeReportAppVersionString)\n"
		fakeReportString += "Code Type:       ARM\n"
		fakeReportString += "\n"
		let enUSPOSIXLocale = NSLocale(localeIdentifier: "en_US_POSIX")
		let rfc3339Formatter = DateFormatter()
		rfc3339Formatter.locale = enUSPOSIXLocale as Locale
		rfc3339Formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
		rfc3339Formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
		let fakeCrashTimestamp = rfc3339Formatter.string(from: Date())
		// we use the current date, since we don't know when the kill actually happened
		fakeReportString += "Date/Time:       \(fakeCrashTimestamp)\n"
		fakeReportString += "OS Version:      \(fakeReportOSVersionString)\n"


		let errorLine = report.lines[1]

		fakeReportString += "Report Version:  104\n"
		fakeReportString += "\n"
		fakeReportString += "Exception Type:  SIGABRT\n"
		fakeReportString += "Exception Codes: \(errorLine.hashValue)\n"
		fakeReportString += "\n"
		fakeReportString += "Application Specific Information:\n\(errorLine)\n\n"
		fakeReportString += report

		fakeReportString += "\n\n"
		let fakeReportFilename = String(format: "%.0f", Date.timeIntervalSinceReferenceDate)

		var rootObj = [AnyHashable : Any](minimumCapacity: 2)
		rootObj["BITFakeCrashUUID"] = fakeReportUUID
		if fakeReportAppMarketingVersion != nil {
			rootObj["BITFakeCrashAppMarketingVersion"] = fakeReportAppMarketingVersion
		}
		rootObj["BITFakeCrashAppVersion"] = fakeReportAppVersion
		rootObj["BITFakeCrashAppBundleIdentifier"] = fakeReportAppBundleIdentifier
		rootObj["BITFakeCrashOSVersion"] = fakeReportOSVersion
		rootObj["BITFakeCrashDeviceModel"] = fakeReportDeviceModel
		rootObj["BITFakeCrashAppBinaryUUID"] = fakeReportAppUUIDs
		rootObj["BITFakeCrashAppString"] = fakeReportString

		let plist = try? PropertyListSerialization.data(fromPropertyList: rootObj, format:.binary, options: 0)
		if let plist = plist {
			let url = URL(fileURLWithPath: bit_settingsDir()!).appendingPathComponent("\(fakeReportFilename).fake")
			try? plist.write(to: url)
		} else {
			print("report error")
		}
	}
}

extension String {
	var lines: [String] {
		var result: [String] = []
		enumerateLines { line, _ in result.append(line) }
		return result
	}
}
