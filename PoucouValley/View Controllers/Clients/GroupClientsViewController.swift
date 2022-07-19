//
//  GroupClientsViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-07-19.
//

import UIKit

class GroupClientsViewController: BaseViewController {
    var type: ClientGroupTypes!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var icons: [UIView]!
    @IBOutlet weak var usersCountLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var clients: [Client]? {
        didSet {
            shouldSearch(text: searchBar.text ?? "" )
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
    }
    
    override func setup() {
        super.setup()
        
        delayTimer.delegate = self
        title = type.title()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    private func loadData() {
        let callBack: (Result<FetchClientsResponse, Error>) -> Void = { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            
            switch result {
            case .success(let response):
                self.clients = Array(response.data)
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

extension GroupClientsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showingClients.count
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
        cell.config(client: client)
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
