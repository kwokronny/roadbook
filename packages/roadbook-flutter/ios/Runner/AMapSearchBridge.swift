import Flutter
#if !targetEnvironment(simulator)
import AMapSearchKit
#endif

class AMapSearchBridge: NSObject {
  private let channel: FlutterMethodChannel
  #if !targetEnvironment(simulator)
  private let searchAPI = AMapSearchAPI()!
  private var pendingResult: FlutterResult?
  #endif

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "com.roadbook/amap_search", binaryMessenger: messenger)
    super.init()
    #if !targetEnvironment(simulator)
    searchAPI.delegate = self
    #endif
    channel.setMethodCallHandler(handle)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "searchPOI":
      #if targetEnvironment(simulator)
      result(FlutterError(code: "SIMULATOR", message: "Not available on simulator", details: nil))
      #else
      guard let args = call.arguments as? [String: Any],
            let keyword = args["keyword"] as? String else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing keyword", details: nil))
        return
      }
      let city = args["city"] as? String ?? ""
      let request = AMapPOIKeywordsSearchRequest()
      request.keywords = keyword
      request.city = city
      request.cityLimit = !city.isEmpty && city != "全国"
      pendingResult = result
      searchAPI.aMapPOIKeywordsSearch(request)
      #endif

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

#if !targetEnvironment(simulator)
extension AMapSearchBridge: AMapSearchDelegate {
  func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
    guard let result = pendingResult else { return }
    pendingResult = nil

    let pois: [[String: Any]] = (response.pois ?? []).map { poi in
      [
        "id": poi.uid ?? "",
        "name": poi.name ?? "",
        "address": poi.address ?? "",
        "location": "\(poi.location?.longitude ?? 0),\(poi.location?.latitude ?? 0)",
        "type": poi.type ?? "",
      ]
    }
    result(pois)
  }

  func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
    guard let result = pendingResult else { return }
    pendingResult = nil
    result(FlutterError(code: "SEARCH_ERROR", message: error.localizedDescription, details: nil))
  }
}
#endif
