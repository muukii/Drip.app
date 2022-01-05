import CompositionKit
import FluidInterfaceKit
import BrightroomEngine

public final class StartupViewController: FluidStackViewController {

  public override func viewDidLoad() {
    super.viewDidLoad()

    do {
      ColorCubeStorage.default.filters = try ColorCubeLoader(bundle: .main).load()
    } catch {
      assertionFailure("Failed to load")
    }

    addContentViewController(StartEditingViewController(), transition: .noAnimation)
  }
}
