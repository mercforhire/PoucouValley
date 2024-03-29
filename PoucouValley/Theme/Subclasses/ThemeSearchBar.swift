//
//  ThemeSearchBar.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-23.
//

import UIKit

class ThemeSearchBar: UISearchBar {

    private var observer: NSObjectProtocol?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupUI()
    }
    
    func setupUI() {
        backgroundImage = UIImage()
        barTintColor = UIColor.fromRGBString(rgbString: themeManager.themeData!.whiteBackground)
        searchTextField.backgroundColor = UIColor.fromRGBString(rgbString: themeManager.themeData!.whiteBackground)
        searchTextField.textColor = UIColor.fromRGBString(rgbString: themeManager.themeData!.textLabel)
        // addBorder(color: UIColor.fromRGBString(rgbString: theme.borderColor!)!)
        roundCorners(style: .medium)
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI()
            }
        }
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
