//
//  CommonUtils.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-21.
//

import Foundation
import UIKit

typealias Action = () -> Void

class Notifications {
    static let HomeScreenShowTopBar: Notification.Name = Notification.Name("HomeScreenShowTopBar")
    static let HomeScreenHideTopBar: Notification.Name = Notification.Name("HomeScreenHideTopBar")
}

func showErrorDialog(error: String) {
    DispatchQueue.main.async {
        guard let topVC = UIViewController.topViewController else { return }
        
        let ac = UIAlertController(title: "", message: error, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Okay", style: .default)
        ac.addAction(cancelAction)
        topVC.present(ac, animated: true)
    }
}

func showNetworkErrorDialog() {
    DispatchQueue.main.async {
        guard let topVC = UIViewController.topViewController else { return }
        
        let ac = UIAlertController(title: "", message: "Network error, please check Internet connection.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Okay", style: .default)
        ac.addAction(cancelAction)
        topVC.present(ac, animated: true)
    }
}

func fileSize(forURL url: Any) -> Double {
    var fileURL: URL?
    var fileSize: Double = 0.0
    if (url is URL) || (url is String) {
        if (url is URL) {
            fileURL = url as? URL
        }
        else {
            fileURL = URL(fileURLWithPath: url as! String)
        }
        var fileSizeValue = 0.0
        try? fileSizeValue = (fileURL?.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).allValues.first?.value as! Double?)!
        if fileSizeValue > 0.0 {
            fileSize = (Double(fileSizeValue) / (1024 * 1024))
        }
    }
    return fileSize
}

func fileSize(forData data: Data) -> Double {
    let fileSize = Double(data.count / 1048576)
    return fileSize
}

func openURLInBrowser(url: URL) {
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
}
