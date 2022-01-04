import CompositionKit
import FluidInterfaceKit

public final class StartupViewController: FluidStackViewController {

  public override func viewDidLoad() {
    super.viewDidLoad()

    addContentViewController(StartEditingViewController(), transition: .noAnimation)
  }
}
