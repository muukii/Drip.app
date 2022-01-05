import AppResource
import BrightroomEngine
import CompositionKit
import FluidInterfaceKit
import Foundation
import Photos
import UIKit

public final class StartupViewController: FluidStackViewController {

  public override func viewDidLoad() {
    super.viewDidLoad()

    Task {

      await withTaskGroup(of: Void.self) { group in
        group.addTask { [weak self] in
          guard let self = self else { return }
          await self.setupPermissionToAccess()
        }
        group.addTask {
          do {
            let bundle = Bundle.main
              .path(forResource: "Filters", ofType: "bundle")
              .map { Bundle(path: $0)! }!
            ColorCubeStorage.default.filters = try ColorCubeLoader(bundle: bundle).load()
          } catch {
            assertionFailure("Failed to load")
          }

        }
      }

      addContentViewController(StartEditingViewController(), transition: .noAnimation)

    }

    let token = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { [weak self] _ in

      guard let self = self else { return }

      Task {
        await self.setupPermissionToAccess()
      }

    }

    // for now
    _ = Unmanaged.passUnretained(token).retain()

  }

  @MainActor
  private func setupPermissionToAccess() async {

    switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
    case .authorized:
      break
    case .denied:

      let alert = UIAlertController.init(
        title: Strings(ja: "写真へのアクセスを許可してください", en: "You need to give this app access to Photos")
          .string(),
        message: Strings(ja: "", en: "").string(),
        preferredStyle: .alert
      )

      alert.addAction(
        .init(
          title: Strings(ja: "設定", en: "Open settings").string(),
          style: .default,
          handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
              UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
          }
        )
      )

      present(alert, animated: true, completion: nil)
    case .limited:

      let alert = UIAlertController.init(
        title: Strings(ja: "全ての写真へのアクセスを許可してください", en: "You need to give this app access to all photos")
          .string(),
        message: Strings(ja: "", en: "").string(),
        preferredStyle: .alert
      )

      alert.addAction(
        .init(
          title: Strings(ja: "設定", en: "Open settings").string(),
          style: .default,
          handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
              UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
          }
        )
      )

      present(alert, animated: true, completion: nil)

    case .notDetermined:

      await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) -> Void in
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
          guard let self = self else { return }
          Task {
            continuation.resume()
            await self.setupPermissionToAccess()
          }
        }
      }

    case .restricted:

      let alert = UIAlertController.init(
        title: Strings(
          ja: "写真へのアクセスが制限されています",
          en: "Access to Photos is currently under the restrictions"
        ).string(),
        message: Strings(ja: "", en: "").string(),
        preferredStyle: .alert
      )

      present(alert, animated: true, completion: nil)

    @unknown default:
      break
    }

  }
}
