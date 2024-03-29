//
//  UIViewController+Extension.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-25.
//

import Foundation
import UIKit

extension UIViewController {
    var themeManager: ThemeManager {
        return ThemeManager.shared
    }
    
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var sceneDelegate: SceneDelegate? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = windowScene.delegate as? SceneDelegate else { return nil }
        return delegate
    }
    
    func addNavLogo() {
        let container = UIView()
        let imageView = UIImageView(image: UIImage(named: "navLogo"))
        imageView.tintColor = themeManager.themeData!.darkerGreen.hexColor
        imageView.contentMode = .scaleAspectFit
        imageView.frame = container.bounds
        container.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 5).isActive = true
        imageView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -5).isActive = true
        imageView.rightAnchor.constraint(equalTo: container.rightAnchor, constant: 0).isActive = true
        navigationItem.titleView = container
    }
    
    func generateRandomSize(collectionView: UICollectionView) -> CGSize {
        let width: Double = Double(collectionView.frame.width) - 10 * 3
        let random = Double(arc4random_uniform(UInt32(width * 1.5)))
        let randomSize = CGSize(width: width, height: max(width + 100, width + random))
        return randomSize
    }
}

extension UIViewController {
    static var window: UIWindow? {
        if #available(iOS 13, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let delegate = windowScene.delegate as? SceneDelegate, let window = delegate.window else { return nil }
            return window
        }
        
        guard let delegate = UIApplication.shared.delegate as? AppDelegate, let window = delegate.window else { return nil }
        
        return window
    }
    
    static var topViewController: UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        
        return keyWindow?.topViewController()
    }
}
