//
//  ProfileDetailsHeader.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-13.
//

import UIKit
import GSKStretchyHeaderView
import UILabel_Copyable

class ClientDetailsHeader: GSKStretchyHeaderView {
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var avatar: URLImageView!
    @IBOutlet weak var navigationTitleLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    func setupUI() {
        cardNumberLabel.isCopyingEnabled = true
        
        avatar.roundCorners(style: .completely)
        avatar.layer.borderColor = UIColor.white.cgColor
        avatar.layer.borderWidth = 2.0
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI()
            }
        }
    }
    
    func config(data: Client) {
        navigationTitleLabel.text = data.fullName
        userNameLabel.text = data.fullName
        createdDateLabel.text = "Created on \(DateUtil.convert(input: data.createdDate, outputFormat: .format5) ?? "--")"
        
        if let cardNumber = data.card {
            cardNumberLabel.text = cardNumber
            cardNumberLabel.isHidden = false
        } else {
            cardNumberLabel.text = ""
            cardNumberLabel.isHidden = true
        }
        
        if let urlString = data.avatar?.thumbnailUrl, let url = URL(string: urlString) {
            avatar.kf.setImage(with: url)
        }
    }
    
    override func didChangeStretchFactor(_ stretchFactor: CGFloat) {
        var alpha = CGFloatTranslateRange(stretchFactor, 0.2, 0.8, 0, 1)
        alpha = max(0, min(1, alpha))

        avatar.alpha = alpha
        userNameLabel.alpha = alpha
        createdDateLabel.alpha = alpha
        
        let navTitleFactor: CGFloat = 0.4
        var navTitleAlpha: CGFloat = 0
        if stretchFactor < navTitleFactor {
            navTitleAlpha = CGFloatTranslateRange(stretchFactor, 0, navTitleFactor, 1, 0)
        }
        navigationTitleLabel.alpha = navTitleAlpha
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
