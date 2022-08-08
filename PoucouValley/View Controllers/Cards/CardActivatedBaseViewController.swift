//
//  CardActivatedBaseViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-27.
//

import UIKit

class CardActivatedBaseViewController: BaseViewController {

    override func setup() {
        super.setup()
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
