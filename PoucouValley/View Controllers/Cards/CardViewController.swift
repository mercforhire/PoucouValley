//
//  CardViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-24.
//

import UIKit
import UILabel_Copyable

class CardViewController: BaseViewController {

    @IBOutlet weak var link: UILabel!
    @IBOutlet weak var merchantLogoContainer: UIView!
    @IBOutlet weak var merchantLogo: URLImageView!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var cardNumber: UILabel!
    
    private var card: Card? {
        didSet {
            guard let card = card else { return }
            
            if let associatedMerchant = card.associatedMerchant {
                link.isHidden = false
                merchantLogoContainer.isHidden = false
                merchantLogo.loadImageFromURL(urlString: associatedMerchant.logo?.thumbnailUrl, blur: .none)
            } else {
                link.isHidden = true
                merchantLogoContainer.isHidden = true
            }
            cardNumber.text = card.number
            qrCodeImageView.image = UIImage.generateQRCode(from: card.number)
        }
    }
    
    override func setup() {
        super.setup()
        
        navigationController?.navigationBar.isHidden = true
        navigationController?.viewControllers = [self]
        
        link.isHidden = true
        merchantLogoContainer.isHidden = true
        cardNumber.text = currentUser.cardholder?.card ?? "--"
        cardNumber.isCopyingEnabled = true
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.greyishBrown.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadCardInfo()
    }
    
    func loadCardInfo() {
        guard card == nil else { return }
        
        FullScreenSpinner().show()
        api.fetchMyCard { [weak self] result in
            FullScreenSpinner().hide()
            
            switch result {
            case .success(let result):
                if result.success, let card = result.data {
                    self?.card = card
                }
            case .failure(let error):
                showNetworkErrorDialog()
            }
        }
    }
}
