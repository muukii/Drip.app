import BrightroomEngine
import BrightroomUI
import CompositionKit
import FluidInterfaceKit
import MondrianLayout
import UIKit
import Verge

final class EditViewController: CodeBasedViewController, ViewControllerFluidContentType {

  private let previewImageView: ImagePreviewView
  private let presetSelectionView: DynamicContentListView<PreviewFilterPreset>
  private let editingStack: EditingStack

  private var subscriptions = VergeAnyCancellables()

  init(
    editingStack: EditingStack
  ) {

    self.editingStack = editingStack
    self.previewImageView = .init(editingStack: editingStack)
    self.presetSelectionView = .init(
      scrollDirection: .horizontal,
      spacing: 8,
      contentInsetAdjustmentBehavior: .never
    )

    super.init()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    Mondrian.buildSubviews(on: view) {

      VStackBlock(alignment: .fill) {

        previewImageView
          .viewBlock
          .padding(.horizontal, 8)
          .alignSelf(.fill)

        presetSelectionView
          .viewBlock
          .height(80)
      }
      .container(respectingSafeAreaEdges: .all)

    }

    let cellRegistration = DynamicContentListView<PreviewFilterPreset>.CellRegistration<PresetCell>
      .init { cell, indexPath, item in
        cell.setData(item)
      }

    presetSelectionView.setUp(
      cellForItemAt: { collectionView, item, indexPath in
        collectionView.dequeueConfiguredReusableCell(
          using: cellRegistration,
          for: indexPath,
          item: item
        )
      },
      didSelectItemAt: { [unowned self] preset in

        editingStack.set {
          $0.preset = preset.filter
        }

        print(preset)
      }
    )

    editingStack.sinkState { [weak self] state in

      guard let self = self else { return }

      if let loadedState = state.mapIfPresent(\.loadedState) {

        self.presetSelectionView.setContents(loadedState.previewFilterPresets)

      } else {
        let loadingState = state.map(\.loadingState)

      }

    }
    .store(in: &subscriptions)

  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    print(traitCollection, previousTraitCollection, UIColor.systemBackground)
  }

}

extension EditViewController {

  private final class PresetCell: UICollectionViewCell {

    override init(
      frame: CGRect
    ) {
      super.init(frame: frame)

      Mondrian.buildSubviews(on: self) {
        ZStackBlock {
          UILabel()&>.do {
            $0.text = "Hey"
          }
        }
      }
    }

    required init?(
      coder: NSCoder
    ) {
      fatalError("init(coder:) has not been implemented")
    }

    func setData(_ data: PreviewFilterPreset) {

    }
  }

}
