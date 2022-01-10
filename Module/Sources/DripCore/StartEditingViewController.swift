import AppResource
import BrightroomEngine
import CompositionKit
import FluidInterfaceKit
import MondrianLayout
import PhotosUI
import UIKit

public final class StartEditingViewController: FluidStackViewController,
  ViewControllerFluidContentType
{

  private var proxy: PickerDelegateProxy?

  public override func viewDidLoad() {
    super.viewDidLoad()

    definesPresentationContext = true

    let configuration = PHPickerConfiguration(photoLibrary: .shared())&>.modify {
      $0.filter = .any(of: [.images, .livePhotos])
    }

    let controller = PHPickerViewController(configuration: configuration)
    let proxy = PickerDelegateProxy(onDidFinishPicking: { [weak self] results in
      guard let self = self else { return }

      Task {
        await self.startEditing(results: results)
      }
    })

    self.proxy = proxy

    controller.delegate = proxy

    addChild(controller)
    view.addSubview(controller.view)
    controller.view.mondrian.layout.edges(.toSuperview).activate()
    controller.didMove(toParent: self)

    /*
    view.backgroundColor = .systemYellow

    let button = UIButton(
      configuration: .bordered(),
      primaryAction: .init(
        title: "Open",
        handler: { [unowned self] _ in

          Task.init {
            let results = await selectImageFromPicker()

            guard let first = results.first else {
              return
            }

            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [first.assetIdentifier!], options: nil)
            let asset = fetchResult.firstObject!

            let input: PHContentEditingInput? = await withCheckedContinuation { continuation in

              let options = PHContentEditingInputRequestOptions()
              options.isNetworkAccessAllowed = true
              options.canHandleAdjustmentData = { adjustmentData in
                adjustmentData.canHandleInApp()
              }

              asset.requestContentEditingInput(with: options) { input, info in
                continuation.resume(returning: input)
              }
            }

            let editingStack = EditingStack(
              imageProvider: .init(contentEditingInput: input!)!,
              colorCubeStorage: .default
            )

            let controller = InAppEditingContainerViewController(
              asset: asset,
              input: input!,
              editingStack: editingStack
            )

            addContentViewController(controller, transition: .popup())

          }
        }
      )
    )

    Mondrian.buildSubviews(on: view) {
      ZStackBlock {
        button
      }
    }
    */
  }

  @MainActor
  private func startEditing(results: [PHPickerResult]) async {
    guard let first = results.first else {
      return
    }

    let fetchResult = PHAsset.fetchAssets(
      withLocalIdentifiers: [first.assetIdentifier!],
      options: nil
    )
    let asset = fetchResult.firstObject!

    let loadingAlert = UIAlertController(
      title: Strings(ja: "読み込み中", en: "Loading").string(),
      message: nil,
      preferredStyle: .alert
    )
    loadingAlert.modalPresentationStyle = .currentContext

    present(loadingAlert, animated: true, completion: nil)

    let input: PHContentEditingInput? = await withCheckedContinuation { continuation in

      let options = PHContentEditingInputRequestOptions()
      options.isNetworkAccessAllowed = true
      options.canHandleAdjustmentData = { adjustmentData in
        adjustmentData.canHandleInApp()
      }

      let id = asset.requestContentEditingInput(with: options) { input, info in
        continuation.resume(returning: input)
      }

      loadingAlert.addAction(
        .init(
          title: Strings(ja: "キャンセル", en: "Cancel").string(),
          style: .default,
          handler: { _ in
            continuation.resume(returning: nil)
            asset.cancelContentEditingInputRequest(id)
          }
        )
      )
    }

    dismiss(animated: true, completion: nil)

    guard let input = input else {
      return
    }

    let editingStack = EditingStack(
      imageProvider: .init(contentEditingInput: input)!,
      colorCubeStorage: .default
    )

    let controller = InAppEditingContainerViewController(
      asset: asset,
      input: input,
      editingStack: editingStack
    )

    controller.actionHandler = { instance, action in
      switch action {
      case .didCancel:
        instance.fluidStackViewControllerContext?.removeSelf(transition: .vanishing())
      case .didComplete:
        instance.fluidStackViewControllerContext?.removeSelf(transition: .vanishing())
      }
    }

    addContentViewController(controller, transition: .popup())
  }

  @MainActor
  private func selectImageFromPicker() async -> [PHPickerResult] {

    await withCheckedContinuation { continuation in

      let configuration = PHPickerConfiguration(photoLibrary: .shared())&>.modify {
        $0.filter = .any(of: [.images, .livePhotos])
      }

      var ref: Unmanaged<PickerDelegateProxy>?

      let controller = PHPickerViewController(configuration: configuration)
      let proxy = PickerDelegateProxy(onDidFinishPicking: { results in
        controller.dismiss(animated: true, completion: nil)
        continuation.resume(returning: results)
        ref?.release()
      })

      ref = Unmanaged.passRetained(proxy)

      controller.delegate = proxy

      present(controller, animated: true, completion: nil)

    }

  }

}

private final class PickerDelegateProxy: PHPickerViewControllerDelegate {

  private let onDidFinishPicking: ([PHPickerResult]) -> Void

  init(
    onDidFinishPicking: @escaping ([PHPickerResult]) -> Void
  ) {
    self.onDidFinishPicking = onDidFinishPicking
  }

  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    onDidFinishPicking(results)
  }
}
