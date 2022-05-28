//
//  MyProfileViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-10.
//

import UIKit

class MyProfileViewController: BaseViewController {

    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var avatarContainer: UIView!
    @IBOutlet weak var avatarImageView: ThemeBlackImageView!
    @IBOutlet weak var nameLabel: ThemeBlackTextLabel!
    @IBOutlet weak var coinsLabel: ThemeBlackTextLabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var giftcards: [UnsplashPhoto]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func setup() {
        super.setup()
        navigationController?.navigationBar.isHidden = true
        headerContainer.roundCorners(style: .small)
        avatarContainer.roundCorners(style: .completely)
        avatarImageView.roundCorners(style: .completely)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchContent()
    }
    
    
    @IBAction func avatarPressed(_ sender: UIButton) {
        
    }
    
    private func fetchContent(complete: ((Bool) -> Void)? = nil) {
        api.getGiftcards { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.giftcards = response
                complete?(true)
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
                complete?(false)
            }
        }
        
        guard let cardholder = currentUser.cardholder else { return }
        
        avatarImageView
    }
}

extension MyProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return giftcards?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GiftTableViewCell", for: indexPath) as? GiftTableViewCell, let giftcard = giftcards?[indexPath.row] else {
            return GiftTableViewCell()
        }
        
        cell.config(unsplashPhoto: giftcard)
        return cell
    }
}
