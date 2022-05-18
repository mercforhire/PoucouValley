//
//  ThemeTextField.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-07.
//

import UIKit

class ThemeTextField: PaddedTextField {
    private var observer: NSObjectProtocol?
    private var insets: UIEdgeInsets?
    
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
    
    func setupUI(overrideSize: CGFloat? = nil, insets: UIEdgeInsets? = nil) {
        guard let theme = themeManager.themeData else { return }
        
        self.insets = insets ?? self.insets
        borderStyle = .none
        backgroundColor = theme.whiteBackground.hexColor
        addBorder(color: theme.steel.hexColor)
        textColor = theme.textLabel.hexColor
        textInsets = self.insets ?? UIEdgeInsets(top: 13, left: 15, bottom: 13, right: 15)
        roundCorners()
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI(overrideSize: overrideSize, insets: insets)
            }
        }
    }
    
    func removeBorder() {
        layer.borderWidth = 0.0
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
