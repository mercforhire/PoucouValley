//
//  MyCoinsHistoryViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-30.
//

import UIKit
import CRRefresh

class MyCoinsHistoryViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var transactions: [Transaction]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func setup() {
        super.setup()
        
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
        
        navigationController?.isNavigationBarHidden = true
    }

    private func loadData(complete: ((Bool) -> Void)? = nil) {
        transactions == nil ? FullScreenSpinner().show() : nil
        
        switch currentUser.userType {
        case .cardholder:
            api.fetchTransactions { [weak self] result in
                FullScreenSpinner().hide()
                self?.tableView.cr.endHeaderRefresh()
                
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
        case .merchant:
            api.fetchMerchantTransactions { [weak self] result in
                FullScreenSpinner().hide()
                self?.tableView.cr.endHeaderRefresh()
                
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
        default:
            break
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
