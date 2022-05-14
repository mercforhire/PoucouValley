//
//  BaseViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-09.
//

import UIKit
import RealmSwift

class BaseViewController: UIViewController {
    var api: PoucouAPI {
        return PoucouAPI.shared
    }
    
    let realm = try! Realm()
    let app = App(id: YOUR_REALM_APP_ID)
    
    private var observer: NSObjectProtocol?
   
    func setup() {
        // override
        setupTheme()
    }
    
    func setupTheme() {
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        setup()
    }
    
    @IBAction func backPressed(_ sender: UIBarButtonItem? = nil) {
        if let navigationController = navigationController {
            if navigationController.viewControllers.count > 1 {
                navigationController.popViewController(animated: true)
            } else {
                navigationController.dismiss(animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
