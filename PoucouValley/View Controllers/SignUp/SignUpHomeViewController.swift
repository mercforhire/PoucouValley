//
//  SignUpHomeViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-21.
//

import UIKit

class SignUpHomeViewController: BaseViewController {
    private var selectedMode: UserType?
    
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

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpCardholderPressed(_ sender: UIButton) {
        selectedMode = .cardholder
        performSegue(withIdentifier: "goToRegister", sender: self)
    }
    
    @IBAction func signUpBusinessPressed(_ sender: UIButton) {
        selectedMode = .merchant
        performSegue(withIdentifier: "goToRegister", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SignUpViewController {
            vc.mode = selectedMode
        }
    }
}
