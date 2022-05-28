//
//  CardRootViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-26.
//

import UIKit

class CardRootViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.viewControllers = [self]
        goToCorrectScreen()
    }

    func goToCorrectScreen() {
        if currentUser.cardholder?.card != nil {
            performSegue(withIdentifier: "goToCard", sender: self)
        } else {
            performSegue(withIdentifier: "goToActivateCard", sender: self)
        }
    }
}
