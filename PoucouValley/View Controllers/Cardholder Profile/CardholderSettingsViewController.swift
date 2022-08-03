//
//  CardholderDetailsViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-29.
//

import UIKit
import CRRefresh

class CardholderSettingsViewController: BaseViewController {
    
    private enum TableRows: Int {
        case basicInfo
        case contactInfo
        case sectionHeader
        case notification
        case about
        case help
        case delete
        case logout
        
        static func rows() -> [TableRows] {
            return [.basicInfo, .contactInfo, .sectionHeader, .notification, .about, .help, .delete, .logout]
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    private var reason: String = ""
    
    override func setup() {
        super.setup()
        navigationController?.navigationBar.isHidden = true
        
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            /// start refresh
            /// Do anything you want...
            self?.loadData()
        }
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        loadData()
    }

    private func loadData(complete: ((Bool) -> Void)? = nil) {
        userManager.fetchUser { [weak self] success in
            self?.tableView.reloadData()
            complete?(success)
        }
    }
    
    @objc func updatePressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToEditProfile", sender: self)
    }
    
    @objc func logOutPressed(_ sender: UIButton) {
        let ac = UIAlertController(title: "Are you sure?", message: "Log out?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Okay", style: .destructive) { [weak self] _ in
            self?.userManager.logout()
        }
        ac.addAction(yesAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    private func showDeleteConfirmation() {
        let alert = UIAlertController(title: "Delete account", message: "Please select a reason for deleting your account", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Billing Issue", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.reason = "Billing Issue"
            self.showAreYouSure()
        }))
        alert.addAction(UIAlertAction(title: "Dissatisfied with service", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.reason = "Dissatisfied with service"
            self.showAreYouSure()
        }))
        alert.addAction(UIAlertAction(title: "Other", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.reason = "Other"
            self.showAreYouSure()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showAreYouSure() {
        let alert = UIAlertController(title: "Are you sure?", message: "Deleting your profile to create a new account may affect who you see on the platform, and we want you to have the best experience possible.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete account", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.showFinalConfirmationDialog()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showFinalConfirmationDialog() {
        let ac = UIAlertController(title: "Delete account?", message: "This action cannot be undone. Type \"delete\" to confirm.", preferredStyle: .alert)
        ac.addTextField { textfield in
            textfield.keyboardType = .asciiCapable
            textfield.placeholder = "type delete"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(cancelAction)
        let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { [unowned ac] _ in
            if let answer = ac.textFields![0].text {
                if answer == "delete" {
                    FullScreenSpinner().show()
                    self.api.deleteAccount(reason: self.reason) { [weak self] result in
                        
                        FullScreenSpinner().hide()
                        
                        switch result {
                        case .success(let response):
                            if response.success {
                                self?.userManager.logout()
                            } else {
                                showErrorDialog(error: response.message)
                            }
                        case .failure:
                            showNetworkErrorDialog()
                        }
                    }
                } else {
                    showErrorDialog(error: "\"delete\" was not typed, delete account action cancelled")
                }
            } else {
                showErrorDialog(error: "\"delete\" was not typed, delete account action cancelled")
            }
        }
        ac.addAction(confirmAction)
        
        present(ac, animated: true)
    }
}

extension CardholderSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableRows.rows().count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = TableRows.rows()[indexPath.row]
        
        switch row {
        case .notification:
            print("notification")
        case .about:
            print("about")
        case .help:
            print("help")
        case .delete:
            showDeleteConfirmation()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = TableRows.rows()[indexPath.row]
        
        switch row {
        case .basicInfo:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardholderBasicInfoCell", for: indexPath) as? CardholderBasicInfoCell else {
                return CardholderBasicInfoCell()
            }
            cell.config(user: currentUser)
            return cell
        case .contactInfo:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardholderContactInfoCell", for: indexPath) as? CardholderContactInfoCell else {
                return CardholderContactInfoCell()
            }
            cell.config(user: currentUser)
            cell.updateButton.addTarget(self, action: #selector(updatePressed), for: .touchUpInside)
            return cell
        case .sectionHeader:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTableCell", for: indexPath) as? LabelTableCell else {
                return LabelTableCell()
            }
            return cell
        case .notification:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDividerTableCell", for: indexPath) as? LabelDividerCell else {
                return LabelDividerCell()
            }
            cell.label.text = "Notification Setting"
            return cell
        case .about:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDividerTableCell", for: indexPath) as? LabelDividerCell else {
                return LabelDividerCell()
            }
            cell.label.text = "About"
            return cell
        case .help:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDividerTableCell", for: indexPath) as? LabelDividerCell else {
                return LabelDividerCell()
            }
            cell.label.text = "Help"
            return cell
        case .delete:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDividerTableCell", for: indexPath) as? LabelDividerCell else {
                return LabelDividerCell()
            }
            cell.label.text = "Delete Account"
            return cell
        case .logout:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonTableCell", for: indexPath) as? ButtonTableCell else {
                return ButtonTableCell()
            }
            cell.button.addTarget(self, action: #selector(logOutPressed(_:)), for: .touchUpInside)
            return cell
        }
    }
}
