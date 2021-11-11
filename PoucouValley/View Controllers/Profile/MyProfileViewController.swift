//
//  MyProfileViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-10.
//

import UIKit

class MyProfileViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let stretchyHeader = ProfileDetailsHeader.fromNib()! as! ProfileDetailsHeader
    
    private var giftcards: [UnsplashPhoto]? {
        didSet {
            tableView.reloadData()
        }
    }
    private var avatar: UnsplashPhoto? {
        didSet {
            stretchyHeader.configureUI(avatar: avatar)
        }
    }
    
    override func setup() {
        navigationController?.navigationBar.isHidden = true
        super.setup()
        
        tableView.roundCorners(style: .medium)
        
        let headerSize = CGSize(width: tableView.frame.size.width, height: 286)
        stretchyHeader.frame = CGRect(x: 0,
                                      y: 0,
                                      width: headerSize.width,
                                      height: headerSize.height)
        tableView.addSubview(stretchyHeader)
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
        api.getRandomAvatar { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.avatar = response
                
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
