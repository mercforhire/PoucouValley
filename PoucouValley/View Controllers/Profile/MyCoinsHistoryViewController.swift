//
//  MyCoinsHistoryViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-30.
//

import UIKit

class MyCoinsHistoryViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var transactions: [Transaction]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func setup() {
        super.setup()
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchContent()
    }

    private func fetchContent(complete: ((Bool) -> Void)? = nil) {
        transactions == nil ? FullScreenSpinner().show() : nil
        
        api.fetchTransactions { [weak self] result in
            FullScreenSpinner().hide()
            
            switch result {
            case .success(let response):
                if response.success {
                    self?.transactions = Array(response.data)
                } else {
                    showNetworkErrorDialog()
                }
            case .failure:
                showNetworkErrorDialog()
            }
        }
    }
}

extension MyCoinsHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionCell,
                let transaction = transactions?[indexPath.row] else {
            return TransactionCell()
        }
        
        cell.config(data: transaction)
        return cell
    }
}