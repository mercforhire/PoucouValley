//
//  ThemeIndigoLabel.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-09-11.
//

import UIKit

class ThemeDarkLabel: UILabel {
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
        textColor = themeManager.themeData!.dark.hexColor
        
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

class ThemeGreyLabel: UILabel {
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
        textColor = themeManager.themeData!.steel.hexColor
        
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

class ThemeBlackTextLabel: UILabel {
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
        textColor = themeManager.themeData!.textLabel.hexColor
        
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

class ThemeGreenTextLabel: UILabel {
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
        textColor = themeManager.themeData!.lighterGreen.hexColor
        
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

class ThemeWhiteTextLabel: UILabel {
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
        textColor = themeManager.themeData!.whiteBackground.hexColor
        
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
