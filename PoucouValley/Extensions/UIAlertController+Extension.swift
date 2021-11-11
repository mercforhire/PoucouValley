//
//  UIAlertController+Extension.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-07.
//

import Foundation
import UIKit

extension UIAlertController {
    func handlePopupInBigScreenIfNeeded(sourceView: UIView, permittedArrowDirections: UIPopoverArrowDirection? = nil) {
        func handlePopupInBigScreen(sourceView: UIView, permittedArrowDirections: UIPopoverArrowDirection? = nil) {
            // https://stackoverflow.com/a/27823616/288724
            popoverPresentationController?.permittedArrowDirections = permittedArrowDirections ?? .any
            popoverPresentationController?.sourceView = sourceView
            popoverPresentationController?.sourceRect = sourceView.bounds
        }

        if #available(macCatalyst 14.0, iOS 14.0, *) {
            if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac {
                handlePopupInBigScreen(sourceView: sourceView, permittedArrowDirections: permittedArrowDirections)
            }
        } else {
            if UIDevice.current.userInterfaceIdiom == .pad {
                handlePopupInBigScreen(sourceView: sourceView, permittedArrowDirections: permittedArrowDirections)
            }
        }
    }
}
