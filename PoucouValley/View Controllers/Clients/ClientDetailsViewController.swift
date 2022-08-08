//
//  ClientDetailsViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-07-06.
//

import UIKit
import PhoneNumberKit

class ClientDetailsViewController: BaseViewController {
    private enum ClientDetailsRows: Int {
        case contactSection
        case email
        case phone
        case divider1
        case infoSection
        case gender
        case birthday
        case address
        case company
        case jobTitle
        case divider2
        case socialSection
        case websiteLink
        case twitterLink
        case facebookLink
        case instagramLink
        case tagsSection
        case tags
        case divider3
        case notesSection
        case notes
        
        func title() -> String {
            switch self {
            case .contactSection:
                return "Contact Info"
            case .email:
                return "Email"
            case .phone:
                return "Phone"
            case .divider1:
                return "DIVIDER"
            case .infoSection:
                return "Basic Info"
            case .gender:
                return "Gender"
            case .birthday:
                return "Birthday"
            case .address:
                return "Address"
            case .company:
                return "Company"
            case .jobTitle:
                return "Job title"
            case .divider2:
                return "DIVIDER"
            case .socialSection:
                return "Social Profile"
            case .websiteLink:
                return ""
            case .twitterLink:
                return ""
            case .facebookLink:
                return ""
            case .instagramLink:
                return ""
            case .tagsSection:
                return "Tags"
            case .tags:
                return ""
            case .divider3:
                return "DIVIDER"
            case .notesSection:
                return "Notes"
            case .notes:
                return ""
            }
        }
        
        static func rows(client: Client) -> [ClientDetailsRows] {
            var rows: [ClientDetailsRows] = [.contactSection,
                                             .email,
                                             .phone,
                                             .divider1,
                                             .infoSection,
                                             .gender,
                                             .birthday,
                                             .address,
                                             .company,
                                             .jobTitle,
                                             .divider2,
                                             .socialSection,
                                             .tagsSection,
                                             .tags,
                                             .divider3,
                                             .notesSection,
                                             .notes]
            
            if !(client.contact?.website?.isEmpty ?? false) {
                rows.insert(.websiteLink,
                            at: ClientDetailsRows.tagsSection.rawValue - 1)
            }
            if !(client.contact?.twitter?.isEmpty ?? false) {
                rows.insert(.twitterLink,
                            at: ClientDetailsRows.tagsSection.rawValue - 1)
            }
            if !(client.contact?.facebook?.isEmpty ?? false) {
                rows.insert(.facebookLink,
                            at: ClientDetailsRows.tagsSection.rawValue - 1)
            }
            if !(client.contact?.instagram?.isEmpty ?? false) {
                rows.insert(.instagramLink,
                            at: ClientDetailsRows.tagsSection.rawValue - 1)
            }
            
            return rows
        }
    }
    
    var client: Client!
    
    @IBOutlet weak var tableView: UITableView!
    
    private let stretchyHeader = ClientDetailsHeader.fromNib()! as! ClientDetailsHeader
    private let phoneNumberKit = PhoneNumberKit()
    
    override func setup() {
        super.setup()
        
        let headerSize = CGSize(width: tableView.frame.size.width, height: 200)
        stretchyHeader.frame = CGRect(x: 0,
                                      y: 0,
                                      width: headerSize.width,
                                      height: headerSize.height)
        tableView.addSubview(stretchyHeader)
        stretchyHeader.backButton.addTarget(self, action: #selector(backPressed(_:)), for: .touchUpInside)
        stretchyHeader.editButton.addTarget(self, action: #selector(editPressed(_:)), for: .touchUpInside)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        
        api.fetchClient(clientId: client.identifier) { [weak self] result in
            switch result {
            case .success(let response):
                if response.success, let client = response.data {
                    self?.client = client
                    self?.refreshUI()
                } else {
                    showErrorDialog(error: response.message)
                }
            case .failure:
                showNetworkErrorDialog()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }

    private func refreshUI() {
        stretchyHeader.config(data: client)
        tableView.reloadData()
    }
    
    @objc func editPressed(_ sender: UIBarButtonItem? = nil) {
        performSegue(withIdentifier: "goToEdit", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditClientViewController {
            vc.client = client
        }
    }
}

extension ClientDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ClientDetailsRows.rows(client: client).count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = ClientDetailsRows.rows(client: client)[indexPath.row]
        switch row {
        case .contactSection, .infoSection, .socialSection, .tagsSection, .notesSection:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTableCell", for: indexPath) as? LabelTableCell else {
                return LabelTableCell()
            }
            cell.headerLabel.text = row.title()
            return cell
        
        case .divider1, .divider2, .divider3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DividerCell", for: indexPath) as? DividerCell else {
                return DividerCell()
            }
            return cell
            
        case .email:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabelsDividerCell", for: indexPath) as? LabelsDividerCell else {
                return LabelsDividerCell()
            }
            cell.label.text = row.title()
            cell.label2.text = client.email ?? "--"
            cell.divider.isHidden = true
            return cell
            
        case .phone:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabelsDividerCell", for: indexPath) as? LabelsDividerCell else {
                return LabelsDividerCell()
            }
            cell.label.text = row.title()
            if let contact = client.contact,
                let phoneNumber = try? phoneNumberKit.parse("\(contact.phoneAreaCode ?? "")\(contact.phoneNumber ?? "")")  {
                cell.label2.text = phoneNumber.numberString
            } else {
                cell.label2.text = "\(client.contact?.phoneAreaCode ?? "")\(client.contact?.phoneNumber ?? "")"
            }
            
            cell.divider.isHidden = true
            return cell
            
        case .gender:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabelsDividerCell", for: indexPath) as? LabelsDividerCell else {
                return LabelsDividerCell()
            }
            cell.label.text = row.title()
            cell.label2.text = client.gender ?? "--"
            cell.divider.isHidden = true
            return cell
            
        case .birthday:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabelsDividerCell", for: indexPath) as? LabelsDividerCell else {
                return LabelsDividerCell()
            }
            cell.label.text = row.title()
            cell.label2.text = client.birthday?.dateString ?? "--"
            cell.divider.isHidden = true
            return cell
            
        case .address:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabelsDividerCell", for: indexPath) as? LabelsDividerCell else {
                return LabelsDividerCell()
            }
            cell.label.text = row.title()
            cell.label2.text = client.address?.addressString ?? "--"
            cell.divider.isHidden = true
            return cell
            
        case .company:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabelsDividerCell", for: indexPath) as? LabelsDividerCell else {
                return LabelsDividerCell()
            }
            cell.label.text = row.title()
            cell.label2.text = client.company ?? "--"
            cell.divider.isHidden = true
            return cell
            
        case .jobTitle:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabelsDividerCell", for: indexPath) as? LabelsDividerCell else {
                return LabelsDividerCell()
            }
            cell.label.text = row.title()
            cell.label2.text = client.jobTitle ?? "--"
            cell.divider.isHidden = true
            return cell
            
        case .websiteLink:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "IconLinkCell", for: indexPath) as? IconLinkCell else {
                return IconLinkCell()
            }
            cell.configWebsite(url: client.contact?.website)
            return cell
            
        case .twitterLink:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "IconLinkCell", for: indexPath) as? IconLinkCell else {
                return IconLinkCell()
            }
            cell.configTwitter(twitterName: client.contact?.twitter)
            return cell
            
        case .facebookLink:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "IconLinkCell", for: indexPath) as? IconLinkCell else {
                return IconLinkCell()
            }
            cell.configFacebook(facebookName: client.contact?.facebook)
            return cell
            
        case .instagramLink:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "IconLinkCell", for: indexPath) as? IconLinkCell else {
                return IconLinkCell()
            }
            cell.configInstagram(igName: client.contact?.instagram)
            return cell
            
        case .tags:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HashTagsTableViewCell", for: indexPath) as? HashTagsTableViewCell else {
                return HashTagsTableViewCell()
            }
            cell.config(tags: Array(client.hashtags), showPlusButton: false, finishAction: { [weak self] in
                guard let tableView = self?.tableView else { return }
                
                self?.refreshTableCellHeights(tableView: tableView)
            })
            return cell
            
        case .notes:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabelsDividerCell", for: indexPath) as? LabelsDividerCell else {
                return LabelsDividerCell()
            }
            cell.label.text = row.title()
            cell.label2.text = client.notes
            cell.divider.isHidden = true
            return cell
        }
    }
}
