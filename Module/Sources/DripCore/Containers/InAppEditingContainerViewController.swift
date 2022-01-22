//
//  File.swift
//
//
//  Created by Muukii on 2022/01/07.
//

import AppResource
import BrightroomEngine
import CompositionKit
import FluidInterfaceKit
import Foundation
import MondrianLayout
import Photos
import UIKit

final class InAppEditingContainerViewController: CodeBasedViewController 
{

  enum Action {
    case didCancel
    case didComplete
  }

  var actionHandler: (InAppEditingContainerViewController, Action) -> Void = { _, _ in assertionFailure() }

  private let contentViewController: EditorViewController
  private let input: PHContentEditingInput
  private let asset: PHAsset
  private let editingStack: EditingStack

  init(
    asset: PHAsset,
    input: PHContentEditingInput,
    editingStack: EditingStack
  ) {
    self.input = input
    self.asset = asset
    self.editingStack = editingStack
    self.contentViewController = EditorViewController(editingStack: editingStack)
    super.init()
    definesPresentationContext = true
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    addChild(contentViewController)
    view.addSubview(contentViewController.view)
    contentViewController.didMove(toParent: self)

    Mondrian.buildSubviews(on: view) {
      ZStackBlock(alignment: .attach(.all)) {
        contentViewController.view
      }
    }

    let navigationView = NavigationHostingView()
    navigationView.setup(on: self)

    let cancelButton = UIButton(
      configuration: .plain(),
      primaryAction: .init(title: Strings(ja: "キャンセル", en: "Cancel").string()) { [unowned self] _ in
        actionHandler(self, .didCancel)
      }
    )

    let doneButton = UIButton(
      configuration: .plain(),
      primaryAction: .init(title: Strings(ja: "完了", en: "Done").string()) { [unowned self] _ in

        PHPhotoLibrary.shared().performChanges {

          do {
            let request = PHAssetChangeRequest(for: asset)
            let output = PHContentEditingOutput(contentEditingInput: input)

            try updateEditingOutput(editingStack: self.editingStack, output: output)

            request.contentEditingOutput = output

          } catch {
            assertionFailure("\(error)")
          }

        } completionHandler: { success, error in
         
          Task { @MainActor in

            if success {
              actionHandler(self, .didComplete)
            } else {

              let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
              alert.addAction(.init(title: "OK", style: .default, handler: nil))
              alert.modalPresentationStyle = .currentContext
              present(alert, animated: true, completion: nil)

            }

          }

        }
      }
    )

    let navigationContentView = AnyView { view in
      HStackBlock {
        cancelButton

        StackingSpacer(minLength: 0)

        doneButton
      }
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
    }

    navigationView.setContent(navigationContentView)

  }
}
