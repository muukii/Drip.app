import AppResource
import BrightroomEngine
import CompositionKit
import FluidInterfaceKit
import Foundation
import Photos
import UIKit

struct PresetEmbeddedInfo: Hashable {

  let color: UIColor
}

func loadPresets() {

  struct PresetCatalog: Decodable {

    struct Preset: Decodable {
      let id: String
      let name: String
    }

    struct Group: Decodable {
      let id: String
      let keyColorHex: String
      let name: String
      let presets: [Preset]
    }

    let groups: [Group]

  }

  do {
    let bundle = Bundle.main
      .path(forResource: "Filters", ofType: "bundle")
      .map { Bundle(path: $0)! }!

    let decoder = JSONDecoder()

    let jsonData = bundle.path(forResource: "presets", ofType: "json")
      .flatMap {
        try? Data(contentsOf: URL(fileURLWithPath: $0))
      }!

    let catalog = try decoder.decode(PresetCatalog.self, from: jsonData)

    var presets: [FilterPreset] = []

    for group in catalog.groups {

      for preset in group.presets {

        let lutPath = bundle.path(forResource: "\(group.id)_\(preset.id)", ofType: "png")!

        let dataProvider = CGDataProvider(url: URL(fileURLWithPath: lutPath) as CFURL)!
        let imageSource = CGImageSourceCreateWithDataProvider(dataProvider, nil)!

        let filter = FilterColorCube(
          name: "\(group.id).\(preset.id)",
          identifier: "\(group.id).\(preset.id)",
          lutImage: .init(cgImageSource: imageSource),
          dimension: 64
        )

        let preset = FilterPreset(
          name: "\(group.id).\(preset.id)",
          identifier: "\(group.id).\(preset.id)",
          filters: [filter.asAny()],
          userInfo: [
            "info": PresetEmbeddedInfo(
              color: .init(hexP3: group.keyColorHex, _unused_colorLiteral: nil)
            )
          ]
        )

        presets.append(preset)

      }

    }

    PresetStorage.default.presets = presets
  } catch {
    assertionFailure("\(error)")
  }
}

public final class StartupViewController: FluidStackController {

  public override func viewDidLoad() {
    super.viewDidLoad()

    Task {

      await withTaskGroup(of: Void.self) { group in
        group.addTask { [weak self] in
          guard let self = self else { return }
          await self.setupPermissionToAccess()
        }
        group.addTask {
          loadPresets()
        }
      }

      addContentViewController(StartEditingViewController(), transition: .noAnimation)

    }

    let token = NotificationCenter.default.addObserver(
      forName: UIApplication.willEnterForegroundNotification,
      object: nil,
      queue: nil
    ) { [weak self] _ in

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
        title: Strings(
          ja: "全ての写真へのアクセスを許可してください",
          en: "You need to give this app access to all photos"
        )
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
