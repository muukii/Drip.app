import BrightroomEngine
import BrightroomUI
import CompositionKit
import FluidInterfaceKit
import MondrianLayout
import UIKit

final class EditViewController: CodeBasedViewController, ViewControllerFluidContentType {

  private let previewImageView: ImagePreviewView

  init(
    editingStack: EditingStack
  ) {

    self.previewImageView = .init(editingStack: editingStack)

    super.init()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    let filterSelectionView = HGridView(numberOfColumns: 1)

    filterSelectionView.setContents([])

    Mondrian.buildSubviews(on: view) {

      VStackBlock(alignment: .fill) {

        previewImageView
          .viewBlock
          .padding(.horizontal, 8)
          .alignSelf(.fill)

        filterSelectionView
          .viewBlock
          .height(80)
      }
      .container(respectingSafeAreaEdges: .all)

    }
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    print(traitCollection, previousTraitCollection, UIColor.systemBackground)
  }

}

extension EditViewController {

  private static func makeFilterCell(onTap: @escaping () -> Void) -> UIView {

    return InteractiveView(
      animation: .bodyShrink,
      haptics: .impactOnTouchUpInside(),
      useLongPressGesture: false,
      contentView: AnyView.init { view in

      }
    )

  }
}
