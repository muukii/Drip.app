
import Photos

extension PHAdjustmentData {

  static func make(data: Data) -> PHAdjustmentData {
    return .init(formatIdentifier: "app.muukii.Drip", formatVersion: "1", data: data)
  }

  func canHandleInApp() -> Bool {
    formatIdentifier == "app.muukii.Drip" && formatVersion == "1"
  }

}
