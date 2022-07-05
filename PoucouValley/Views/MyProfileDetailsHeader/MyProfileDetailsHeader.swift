//
//  ProfileDetailsHeader.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-13.
//

import UIKit
import GSKStretchyHeaderView
import Kingfisher

class MyProfileDetailsHeader: GSKStretchyHeaderView {
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var editButtonContainer: UIView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var navigationTitleLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var nameLabelsContainer: UIStackView!
    @IBOutlet weak var pointsContainer: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    func setupUI() {
        avatar.roundCorners(style: .completely)
        avatar.layer.borderColor = UIColor.white.cgColor
        avatar.layer.borderWidth = 2.0
        editButtonContainer.roundCorners(style: .completely)
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI()
            }
        }
    }
    
    func configureUI(data: Cardholder?) {
        navigationTitleLabel.text = data?.fullName
        userNameLabel.text = data?.fullName
        
        if let urlString = data?.avatar?.thumbnailUrl, let url = URL(string: urlString) {
            self.avatar.kf.setImage(with: url)
        }
    }
    
    override func didChangeStretchFactor(_ stretchFactor: CGFloat) {
        var alpha = CGFloatTranslateRange(stretchFactor, 0.2, 0.8, 0, 1)
        alpha = max(0, min(1, alpha))

        avatar.alpha = alpha
        editButtonContainer.alpha = alpha
        nameLabelsContainer.alpha = alpha
        pointsContainer.alpha = alpha

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
