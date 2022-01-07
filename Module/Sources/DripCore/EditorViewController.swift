import BrightroomEngine
import BrightroomUI
import CompositionKit
import FluidInterfaceKit
import MondrianLayout
import UIKit
import Verge

final class EditorViewController: CodeBasedViewController {

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

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        editingStack.set {
          $0.preset = preset.filter
        }

      }
    )

    presetSelectionView.setContentInset(.init(top: 0, left: 8, bottom: 0, right: 8))

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

extension EditorViewController {

  private final class PresetCell: UICollectionViewCell {

    private let imageView = MetalImageView()
    private let colorMarkView = UIView()

    override init(
      frame: CGRect
    ) {
      super.init(frame: frame)

      Mondrian.buildSubviews(on: self) {
        VStackBlock {

          imageView
            .viewBlock
            .width(44)
            .aspectRatio(1)

          colorMarkView
            .viewBlock
            .width(16)
            .height(16)
            .spacingBefore(4)

          StackingSpacer(minLength: 0)
        }
      }

      colorMarkView.layer.cornerCurve = .continuous
      colorMarkView.layer.cornerRadius = 8
    }

    required init?(
      coder: NSCoder
    ) {
      fatalError("init(coder:) has not been implemented")
    }

    func setData(_ data: PreviewFilterPreset) {

      if let info = data.filter.userInfo["info"] as? PresetEmbeddedInfo {
        colorMarkView.backgroundColor = info.color
      } else {
        assertionFailure("")
      }

      imageView.display(image: data.image)

    }
  }

}
