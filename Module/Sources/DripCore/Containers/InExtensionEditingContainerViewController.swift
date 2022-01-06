//
//  PhotoEditingViewController.swift
//  Drip-PhotoEditingExtension
//
//  Created by Muukii on 2022/01/04.
//

import UIKit
import Photos
import PhotosUI
import MondrianLayout
import Wrap
import BrightroomEngine

open class InExtensionEditingContainerViewController: UIViewController, PHContentEditingController {

  public var input: PHContentEditingInput?
  private var editingStack: EditingStack?

  public override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    Mondrian.buildSubviews(on: view) {
      VStackBlock {
        UILabel()&>.do {
          $0.text = "Hey"
          $0.textColor = .label
        }
      }
    }

    // Do any additional setup after loading the view.
  }

  // MARK: - PHContentEditingController

  public func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
    // Inspect the adjustmentData to determine whether your extension can work with past edits.
    // (Typically, you use its formatIdentifier and formatVersion properties to do this.)
    return false
  }

  public func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: UIImage) {
    // Present content for editing, and keep the contentEditingInput for use when closing the edit session.
    // If you returned true from canHandleAdjustmentData:, contentEditingInput has the original image and adjustment data.
    // If you returned false, the contentEditingInput has past edits "baked in".
    input = contentEditingInput

    Task {

      loadPresets()

      let stack = EditingStack(imageProvider: .init(editableRemoteURL: contentEditingInput.fullSizeImageURL!))
      self.editingStack = stack

      await MainActor.run {

        let controller = EditorViewController(editingStack: stack)

        addChild(controller)
        view.addSubview(controller.view)
        controller.view.frame = view.bounds
        controller.didMove(toParent: self)
      }

    }

  }

  public func finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void)) {
    // Update UI to reflect that editing has finished and output is being rendered.

    guard let editingStack = editingStack else {
      preconditionFailure()
    }

    Task.detached { [input] in

      let output = PHContentEditingOutput(contentEditingInput: input!)

      try! updateEditingOutput(editingStack: editingStack, output: output)

      completionHandler(output)
    }

  }

  public var shouldShowCancelConfirmation: Bool {
    // Determines whether a confirmation to discard changes should be shown to the user on cancel.
    // (Typically, this should be "true" if there are any unsaved changes.)
    return false
  }

  public func cancelContentEditing() {
    // Clean up temporary files, etc.
    // May be called after finishContentEditingWithCompletionHandler: while you prepare output.
  }

}

