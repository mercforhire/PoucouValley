//
//  ClientsViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-07-12.
//

import UIKit
import CRRefresh

class ClientsViewController: BaseViewController {

    @IBOutlet var iconContainers: [UIView]!
    
    @IBOutlet weak var searchBar: ThemeSearchBar!
    @IBOutlet weak var usersCountLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var contextButtonsContainer: UIView!
    
    private var clients: [Client]? {
        didSet {
            shouldSearch(text: searchBar.text ?? "")
            usersCountLabel.text = "Users \(clients?.count ?? 0)"
        }
    }
    
    private var showingClients: [Client] = []
    private var selected: [Client] = [] {
        didSet {
            if !selected.isEmpty {
                selectButton.setTitle("Unselect All", for: .normal)
                contextButtonsContainer.isHidden = false
            } else {
                selectButton.setTitle("Select All", for: .normal)
                contextButtonsContainer.isHidden = true
            }
            tableView.reloadData()
        }
    }
    private var clickedClient: Client?
    private var delayTimer = DelayedSearchTimer()
    private lazy var composer: MessageComposer = MessageComposer()
    
    override func setupTheme() {
        super.setupTheme()
        
        for iconContainer in iconContainers {
            iconContainer.roundCorners(style: .completely)
            iconContainer.addBorder(color: .black)
        }
    }
    
    override func setup() {
        super.setup()
        
        delayTimer.delegate = self
        contextButtonsContainer.isHidden = true
        
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
        
        navigationController?.isNavigationBarHidden = false
    }
    
    private func loadData() {
        clients == nil ? FullScreenSpinner().show() : nil
        
        api.fetchClients { [weak self] result in
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
    
    @IBAction func groupsPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToGroups", sender: self)
    }
    
    @IBAction func selectPressed(_ sender: UIButton) {
        if selected.isEmpty {
            selected.append(contentsOf: showingClients)
        } else {
            selected.removeAll()
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        guard !selected.isEmpty else { return }
        
        let ac = UIAlertController(title: "Delete clients", message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            FullScreenSpinner().show()
            
            self.api.deleteClients(clients: self.selected) { [weak self] result in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                
                switch result {
                case .success(let response):
                    if response.success {
                        let notDeleted = self.selected.filter { client in
                            return client.card != nil
                        }
                        if !notDeleted.isEmpty {
                            showErrorDialog(error: "Poucon cardholders can not be deleted.")
                        }
                        self.loadData()
                    } else {
                        showErrorDialog(error: response.message)
                    }
                case .failure:
                    showNetworkErrorDialog()
                }
            }
        }
        ac.addAction(action1)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(cancelAction)
        present(ac, animated: true)
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
}

extension ClientsViewController: DelayedSearchTimerDelegate {
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
            return leftClient.firstName ?? "" < rightClient.firstName ?? ""
        })
        
        tableView.reloadData()
    }
}

extension ClientsViewController: UITableViewDataSource, UITableViewDelegate {
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
