import BrightroomEngine
import Photos

struct EditingState: Codable {

  var name = "Drip"

}

func updateEditingOutput(editingStack: EditingStack, output: PHContentEditingOutput) throws {

  let rendered = try editingStack.makeRenderer().render()
  let imageData = rendered.makeOptimizedForSharingData(dataType: .jpeg(quality: 1))

  let state = EditingState()

  let encoder = JSONEncoder()
  let data = try encoder.encode(state)

  output.adjustmentData = .make(data: data)
  
  try! imageData.write(to: output.renderedContentURL, options: [.atomic])

}
