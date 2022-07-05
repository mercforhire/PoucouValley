//
//  ProfileDetailsHeader.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-13.
//

import UIKit
import GSKStretchyHeaderView

class ClientDetailsHeader: GSKStretchyHeaderView {
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var star: UIView!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var navigationTitleLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    func setupUI() {
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
    
    func configureUI(data: Client) {
        userNameLabel.text = navigationTitleLabel.text
        
        if let urlString = data.avatar?.thumbnailUrl, let url = URL(string: urlString) {
            avatar.kf.setImage(with: url)
        }
    }
    
    override func didChangeStretchFactor(_ stretchFactor: CGFloat) {
        var alpha = CGFloatTranslateRange(stretchFactor, 0.2, 0.8, 0, 1)
        alpha = max(0, min(1, alpha))

        avatar.alpha = alpha
        star.alpha = alpha
        userNameLabel.alpha = alpha

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
