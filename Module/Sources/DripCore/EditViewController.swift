import CompositionKit
import BrightroomEngine
import BrightroomUI
import MondrianLayout
import UIKit
import FluidInterfaceKit

final class EditViewController: CodeBasedViewController, ViewControllerFluidContentType {

  private let previewImageView: ImagePreviewView

  init(editingStack: EditingStack) {

    self.previewImageView = .init(editingStack: editingStack)

    super.init()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    Mondrian.buildSubviews(on: view) {

      VStackBlock {
        previewImageView
          .viewBlock
          .padding(24)
          .alignSelf(.fill)
      }
      .container(respectingSafeAreaEdges: .all)

    }
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    print(traitCollection, previousTraitCollection, UIColor.systemBackground)
  }

}
