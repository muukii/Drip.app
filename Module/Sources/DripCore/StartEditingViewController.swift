import CompositionKit
import FluidInterfaceKit
import MondrianLayout
import PhotosUI
import UIKit
import BrightroomEngine

public final class StartEditingViewController: FluidStackViewController, ViewControllerFluidContentType {

  public override func viewDidLoad() {
    super.viewDidLoad()

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

            let editingStack = EditingStack(
              imageProvider: .init(asset: asset),
              colorCubeStorage: .default
            )

            let controller = InAppEditingContainerViewController(
              asset: asset,
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
  }

  @MainActor
  func selectImageFromPicker() async -> [PHPickerResult] {

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

fileprivate final class PickerDelegateProxy: PHPickerViewControllerDelegate {

  private let onDidFinishPicking: ([PHPickerResult]) -> Void

  init(onDidFinishPicking: @escaping ([PHPickerResult]) -> Void) {
    self.onDidFinishPicking = onDidFinishPicking
  }

  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    onDidFinishPicking(results)
  }
}
