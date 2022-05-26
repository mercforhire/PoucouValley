//
//  LoginHomeViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-17.
//

import UIKit

class LoginHomeViewController: BaseViewController {
    private var selectedMode: UserType?
    
    override func setup() {
        super.setup()
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.userManager.isLoggedIn() {
            print("is loggined in")
            self.loginUser()
        } else {
            print("is not loggined in")
        }
    }
    
    @IBAction func loginCardholderPressed(_ sender: UIButton) {
        selectedMode = .cardholder
        performSegue(withIdentifier: "goToLogin", sender: self)
    }
    
    @IBAction func loginBusinessPressed(_ sender: UIButton) {
        selectedMode = .merchant
        performSegue(withIdentifier: "goToLogin", sender: self)
    }
    
    private func loginUser() {
        FullScreenSpinner().show()
        userManager.loginUsingApiKey() { [weak self] success in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            if success {
                self.userManager.proceedPastLogin()
            } else {
                self.userManager.clearSavedInformation()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LoginViewController {
            vc.mode = selectedMode
        }
    }
}
