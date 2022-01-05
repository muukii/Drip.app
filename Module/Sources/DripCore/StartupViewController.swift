import CompositionKit
import FluidInterfaceKit
import BrightroomEngine
import Foundation

public final class StartupViewController: FluidStackViewController {

  public override func viewDidLoad() {
    super.viewDidLoad()

    do {

      let bundle = Bundle.main
        .path(forResource: "Filters", ofType: "bundle")
        .map { Bundle(path: $0)! }!

      ColorCubeStorage.default.filters = try ColorCubeLoader(bundle: bundle).load()
    } catch {
      assertionFailure("Failed to load")
    }

    addContentViewController(StartEditingViewController(), transition: .noAnimation)
  }
}
