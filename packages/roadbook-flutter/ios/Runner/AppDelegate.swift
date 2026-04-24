import Flutter
import UIKit
import GoogleMaps
#if !targetEnvironment(simulator)
import AMapFoundationKit
#endif

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var searchBridge: AMapSearchBridge?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyBxZbJh5YKN1yy94iJwovr2Br7ZlpudJUg")
    #if !targetEnvironment(simulator)
    AMapServices.shared().apiKey = "4b2a2785e5a357779608d3af1df84ff1"
    #endif

    GeneratedPluginRegistrant.register(with: self)
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    let messenger = self.registrar(forPlugin: "RoadbookPlatformPlugin")!.messenger()

    let platformChannel = FlutterMethodChannel(name: "com.roadbook/platform", binaryMessenger: messenger)
    platformChannel.setMethodCallHandler { call, result in
      if call.method == "isSimulator" {
        #if targetEnvironment(simulator)
        result(true)
        #else
        result(false)
        #endif
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    searchBridge = AMapSearchBridge(messenger: messenger)

    return result
  }
}
