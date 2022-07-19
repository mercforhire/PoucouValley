//
//  GroupsViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-07-15.
//

import UIKit

class GroupsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var data: FetchClientGroupsStatisticsResponse? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var selectedType: ClientGroupTypes?
    
    override func setupTheme() {
        super.setupTheme()
    }
    
    override func setup() {
        super.setup()
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
        data == nil ? FullScreenSpinner().show() : nil
        
        api.fetchClientGroupsStatistics { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            
            switch result {
            case .success(let response):
                self.data = response
            case .failure:
                showNetworkErrorDialog()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GroupClientsViewController,
            let selectedType = selectedType {
            vc.type = selectedType
        }
    }
}

extension GroupsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ClientGroupTypes.getRows().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabelsCell", for: indexPath) as? LabelsCell else {
            return LabelsCell()
        }
        let row = ClientGroupTypes.getRows()[indexPath.row]
        cell.label.text = row.title()
        switch row {
        case .activated:
            if let activatedClients = data?.data?.activatedClients, let totalCards = data?.data?.totalCards {
                cell.label2.text = "\(activatedClients)/\(totalCards)"
            } else {
                cell.label2.text = "--"
            }
            
        case .followed:
            if let followedClients = data?.data?.followedClients {
                cell.label2.text = "\(followedClients)"
            } else {
                cell.label2.text = "--"
            }
        case .inputted:
            if let inputtedClients = data?.data?.inputtedClients {
                cell.label2.text = "\(inputtedClients)"
            } else {
                cell.label2.text = "--"
            }
        case .scanned:
            if let scannedClients = data?.data?.scannedClients {
                cell.label2.text = "\(scannedClients)"
            } else {
                cell.label2.text = "--"
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = ClientGroupTypes.getRows()[indexPath.row]
        selectedType = row
        performSegue(withIdentifier: "goToClientsList", sender: self)
    }
}
