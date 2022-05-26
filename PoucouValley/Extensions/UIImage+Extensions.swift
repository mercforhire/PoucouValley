//
//  UIImage+Extensions.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-21.
//

import Foundation
import UIKit

extension UIImage {
    var jpeg: Data? { jpegData(compressionQuality: 0.9) }  // QUALITY min = 0 / max = 1
    var png: Data? { pngData() }
    
    static func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        if let QRFilter = CIFilter(name: "CIQRCodeGenerator") {
            QRFilter.setValue(data, forKey: "inputMessage")
            guard let QRImage = QRFilter.outputImage else { return nil }
            return UIImage(ciImage: QRImage)
        }
        return nil
    }
}
