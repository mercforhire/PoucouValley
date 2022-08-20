//
//  GroupClientsViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-07-19.
//

import UIKit
import CRRefresh

class GroupClientsViewController: BaseViewController {
    var type: ClientGroupTypes!
    
    @IBOutlet weak var searchBar: ThemeSearchBar!
    @IBOutlet var icons: [UIView]!
    @IBOutlet weak var usersCountLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var clients: [Client]? {
        didSet {
            shouldSearch(text: searchBar.text ?? "" )
            usersCountLabel.text = "Users \(clients?.count ?? 0)"
        }
    }
    
    private var showingClients: [Client] = []
    private var selected: [Client] = [] {
        didSet {
            if !selected.isEmpty {
                selectButton.setTitle("Unselect All", for: .normal)
            } else {
                selectButton.setTitle("Select All", for: .normal)
            }
            tableView.reloadData()
        }
    }
    private var clickedClient: Client?
    private var delayTimer = DelayedSearchTimer()
    private lazy var composer: MessageComposer = MessageComposer()
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func setup() {
        super.setup()
        
        delayTimer.delegate = self
        title = type.title()
        
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            /// start refresh
            /// Do anything you want...
            self?.loadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func loadData() {
        let callBack: (Result<FetchClientsResponse, Error>) -> Void = { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            self.tableView.cr.endHeaderRefresh()
            
            switch result {
            case .success(let response):
                if response.success {
                    let clients = Array(response.data)
                    self.clients = clients
                    self.selected.removeAll()
                } else {
                    showErrorDialog(error: response.message)
                }
            case .failure:
                showNetworkErrorDialog()
            }
        }
        
        clients == nil ? FullScreenSpinner().show() : nil
        
        switch type {
        case .activated:
            api.fetchActivatedClients(callBack: callBack)
        case .followed:
            api.fetchFollowedClients(callBack: callBack)
        case .inputted:
            api.fetchInputtedClients(callBack: callBack)
        case .scanned:
            api.fetchScannedClients(callBack: callBack)
        default:
            break
        }
    }
    
    @IBAction func emailPressed(_ sender: UIButton) {
        guard !selected.isEmpty else { return }
        
        var toRecipients: [String] = []
        if let myEmail = UserManager.shared.user?.user?.email {
            toRecipients.append(myEmail)
        }
        var emails: [String] = []
        for client in selected {
            if let email = client.email {
                emails.append(email)
            }
        }
        
        let vc = composer.configuredEmailComposeViewController(toRecipients: toRecipients, ccRecipients: [], bccRecipients: emails, subject: "", message: "")

        if composer.canSendEmail(), vc != nil {
            present(vc, animated: true)
        } else {
            showErrorDialog(error: "Can't send email on this device.")
        }
    }
    
    @IBAction func messagePressed(_ sender: UIButton) {
        guard !selected.isEmpty else { return }
        
        var phoneNumbers: [String] = []
        for client in selected {
            if let phoneNumber = client.contact?.getPhoneNumberString(), !phoneNumber.isEmpty {
                phoneNumbers.append(phoneNumber)
            }
        }
        
        guard !phoneNumbers.isEmpty else { return }
        
        let vc = composer.configuredMessageComposeViewController(recipients: phoneNumbers, message: "")
        if composer.canSendText(), vc != nil {
            present(vc, animated: true)
        } else {
            showErrorDialog(error: "Can't send SMS on this device.")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ClientDetailsViewController,
            let client = clickedClient {
            vc.client = client
        }
    }
    
    @objc func checkmarkButtonPressed(_ sender: UIButton) {
        let client = showingClients[sender.tag]
        
        if selected.contains(client), let index = selected.firstIndex(of: client) {
            selected.remove(at: index)
        } else {
            selected.append(client)
        }
    }
    
    @IBAction func selectAllPressed(_ sender: UIButton) {
        if !selected.isEmpty {
            // Unselect All
            selected.removeAll()
        } else {
            // Select All
            selected.append(contentsOf: showingClients)
        }
    }
}

extension GroupClientsViewController: DelayedSearchTimerDelegate {
    func shouldSearch(text: String) {
        guard let clients = clients else {
            return
        }
        
        if text.count > 2 {
            showingClients = clients.filter({ client in
                return client.fullName.contains(string: text)
            })
        } else {
            showingClients = clients
        }
        showingClients = showingClients.sorted(by: { leftClient, rightClient in
            return leftClient.firstName ?? "" > rightClient.firstName ?? ""
        })
        
        tableView.reloadData()
    }
}

extension GroupClientsViewController: UISearchBarDelegate {

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if let text = searchBar.text, !text.trim().isEmpty {
            delayTimer.textDidGetEntered(text: text)
        } else {
            delayTimer.textDidGetEntered(text: "")
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        delayTimer.textDidGetEntered(text: "")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        guard let text = searchBar.text, !text.trim().isEmpty else {
            delayTimer.textDidGetEntered(text: "")
            return
        }
        
        delayTimer.textDidGetEntered(text: text)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let text = searchBar.text, !text.trim().isEmpty {
            delayTimer.textDidGetEntered(text: text)
        } else {
            delayTimer.textDidGetEntered(text: "")
        }
    }
}

extension GroupClientsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, showingClients.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showingClients.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyClientCell", for: indexPath)
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClientCell", for: indexPath) as? ClientCell else {
            return ClientCell()
        }
        let client = showingClients[indexPath.row]
        cell.config(client: client,
                    showCheck: true,
                    checked: selected.contains(client))
        cell.checkmarkButton.tag = indexPath.row
        cell.checkmarkButton.addTarget(self, action: #selector(checkmarkButtonPressed), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if showingClients.count == 0 {
            return
        }
        let client = showingClients[indexPath.row]
        clickedClient = client
        performSegue(withIdentifier: "goToClientDetail", sender: self)
    }
}
