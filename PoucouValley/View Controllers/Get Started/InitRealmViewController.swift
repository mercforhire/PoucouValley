//
//  InitRealmViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-07.
//

import UIKit

class InitRealmViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initRealm()
    }
    
    private func initRealm() {
        PoucouAPI.shared.initRealm { [weak self] success in
            guard let self = self else { return }
            
            if !success {
                self.showRetryConnectRealm()
            } else {
                let vc: UIViewController! = StoryboardManager.loadViewController(storyboard: "Login", viewControllerId: "GetStartedViewController")
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
    }

    private func showRetryConnectRealm() {
        let alert = UIAlertController(title: "Fatal error", message: "Fatal error: Failed to connect to Realm server.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
            self.initRealm()
        }))
        present(alert, animated: true, completion: nil)
    }
}
