//
//  ThemeUIPageControl.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-17.
//

import UIKit

class ThemeUIPageControl: UIPageControl {

    private var observer: NSObjectProtocol?
    
    var cornerStyle: RoundCornerStyle = .small {
        didSet {
            roundCorners(style: cornerStyle)
        }
    }
    
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
        pageIndicatorTintColor = themeManager.themeData!.softGreen.hexColor
        currentPageIndicatorTintColor = themeManager.themeData!.lighterGreen.hexColor
        
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
