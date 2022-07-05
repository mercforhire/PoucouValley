//
//  CardholderDetailsViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-29.
//

import UIKit

class CardholderDetailsViewController: BaseViewController {
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
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
}

extension CardholderDetailsViewController: UITableViewDataSource, UITableViewDelegate {
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
            print("delete")
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDividerTableCell", for: indexPath) as? LabelDividerTableCell else {
                return LabelDividerTableCell()
            }
            cell.label.text = "Notification Setting"
            return cell
        case .about:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDividerTableCell", for: indexPath) as? LabelDividerTableCell else {
                return LabelDividerTableCell()
            }
            cell.label.text = "About"
            return cell
        case .help:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDividerTableCell", for: indexPath) as? LabelDividerTableCell else {
                return LabelDividerTableCell()
            }
            cell.label.text = "Help"
            return cell
        case .delete:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDividerTableCell", for: indexPath) as? LabelDividerTableCell else {
                return LabelDividerTableCell()
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
