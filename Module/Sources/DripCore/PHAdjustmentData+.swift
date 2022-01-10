import BrightroomEngine
import Photos

extension PHAdjustmentData {

  static func make(data: Data) -> PHAdjustmentData {
    return .init(formatIdentifier: "app.muukii.Drip", formatVersion: "1", data: data)
  }

  static func make(editingStack: EditingStack) throws -> PHAdjustmentData {

    let identifier = editingStack.state.loadedState!.currentEdit.filters.preset?.identifier

    let state = EditingState(
      name: "",
      presetIdentifier: identifier
    )
    let encoder = JSONEncoder()
    let data = try encoder.encode(state)

    return self.make(data: data)
  }

  func restore(in editingStack: EditingStack) throws {

    let decoder = JSONDecoder()
    let state = try decoder.decode(EditingState.self, from: data)

  }

  func canHandleInApp() -> Bool {
    formatIdentifier == "app.muukii.Drip" && formatVersion == "1"
  }

}

struct EditingState: Codable {

  var name = "Drip"
  var presetIdentifier: String?

}

func updateEditingOutput(editingStack: EditingStack, output: PHContentEditingOutput) throws {

  let rendered = try editingStack.makeRenderer().render()
  let imageData = rendered.makeOptimizedForSharingData(dataType: .jpeg(quality: 1))

  output.adjustmentData = try .make(editingStack: editingStack)

  try imageData.write(to: output.renderedContentURL, options: [.atomic])

}
