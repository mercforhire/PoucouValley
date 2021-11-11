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
        guard let theme = themeManager.themeData?.searchBarTheme else { return }
        
        barTintColor = UIColor.fromRGBString(rgbString: theme.backgroundColor)
        searchTextField.backgroundColor = UIColor.fromRGBString(rgbString: theme.backgroundColor)
        searchTextField.textColor = UIColor.fromRGBString(rgbString: theme.textColor)
        searchTextField.font = theme.font.toFont()
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
