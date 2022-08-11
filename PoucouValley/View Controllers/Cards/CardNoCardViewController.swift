//
//  CardNoCardViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-24.
//

import UIKit

class CardNoCardViewController: BaseViewController {

    override func setup() {
        super.setup()
        
        navigationController?.viewControllers = [self]
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func buyCardPressed(_ sender: UIButton) {
        showErrorDialog(error: "Please contact Poucou customer support.")
    }
    
}
