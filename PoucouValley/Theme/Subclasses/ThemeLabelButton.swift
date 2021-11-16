//
//  ThemeLabelButton.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-23.
//

import UIKit

class ThemeLabelButton: UIButton {
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
        guard let theme = themeManager.themeData?.labelButtonTheme else { return }
        
        titleLabel?.font = theme.font.toFont()
        setTitleColor(UIColor.fromRGBString(rgbString: theme.textColor), for: .normal)
        
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