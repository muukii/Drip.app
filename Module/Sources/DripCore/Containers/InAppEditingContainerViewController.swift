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

final class InAppEditingContainerViewController: CodeBasedViewController,
  ViewControllerFluidContentType
{

  private let contentViewController: EditorViewController
  private let asset: PHAsset
  private let editingStack: EditingStack

  init(
    asset: PHAsset,
    editingStack: EditingStack
  ) {
    self.asset = asset
    self.editingStack = editingStack
    self.contentViewController = EditorViewController(editingStack: editingStack)
    super.init()
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
        fluidStackViewControllerContext?.removeSelf(transition: .vanishing())
      }
    )

    let doneButton = UIButton(
      configuration: .plain(),
      primaryAction: .init(title: Strings(ja: "完了", en: "Done").string()) { [unowned self] _ in

        let options = PHContentEditingInputRequestOptions()

        options.progressHandler = { progress, stop in
          print("Processing", progress, stop)
        }

        options.canHandleAdjustmentData = { data in
          print(data)
          return true
        }

        options.isNetworkAccessAllowed = true

        asset.requestContentEditingInput(with: options) { [weak self] input, userInfo in

          guard let self = self else { return }

          PHPhotoLibrary.shared().performChanges {

            do {

              let request = PHAssetChangeRequest(for: asset)
              let output = PHContentEditingOutput(contentEditingInput: input!)

              try updateEditingOutput(editingStack: self.editingStack, output: output)

              request.contentEditingOutput = output

            } catch {
              assertionFailure("\(error)")
            }

          } completionHandler: { success, error in
            print(success, error?.localizedDescription)
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
