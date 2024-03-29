//
//  MerchantSettingsViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-02.
//

import UIKit

class MerchantSettingsViewController: BaseViewController {

    private enum TableRows: Int {
        case sectionHeader
        case notification
        case about
        case help
        case delete
        case logout
        
        static func rows() -> [TableRows] {
            return [.sectionHeader, .notification, .about, .help, .delete, .logout]
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    private var reason: String = ""
    
    override func setup() {
        super.setup()
        
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
        
    }

    @objc func logOutPressed(_ sender: UIButton) {
        let ac = UIAlertController(title: "Are you sure?", message: "Log out?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Log out", style: .destructive) { [weak self] _ in
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
    
    private func showNotificationSettings() {
        let alert = UIAlertController(title: "Push notification settings", message: "Please select the notification allowance level", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "All" + (currentUser.user?.settings?.notification == .all ? "(Selected)" : ""),
                                      style: .default,
                                      handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.updateNotificationSettings(settings: .all)
        }))
        alert.addAction(UIAlertAction(title: "Important actions only" + (currentUser.user?.settings?.notification == .actions ? "(Selected)" : ""),
                                      style: .default,
                                      handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.updateNotificationSettings(settings: .actions)
        }))
        alert.addAction(UIAlertAction(title: "Off" + (currentUser.user?.settings?.notification == .off ? "(Selected)" : ""),
                                      style: .default,
                                      handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.updateNotificationSettings(settings: .off)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func updateNotificationSettings(settings: NotificationSettings) {
        FullScreenSpinner().show()
        userManager.changeUserSettings(notification: settings) { _ in
            FullScreenSpinner().hide()
        }
    }
}

extension MerchantSettingsViewController: UITableViewDataSource, UITableViewDelegate {
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
            showNotificationSettings()
        case .about:
            openURLInBrowser(url: URL(string: "http://poncouvalley.com/")!)
        case .help:
            openURLInBrowser(url: URL(string: "http://poncouvalley.com/")!)
        case .delete:
            showDeleteConfirmation()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = TableRows.rows()[indexPath.row]
        
        switch row {
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
