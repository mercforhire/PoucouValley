//
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-05.
//

import UIKit

public class ThemeLabel: UILabel {
    private var observer: NSObjectProtocol?
    
    var theme: TextLabelTheme?
    
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
    
    func setupUI(overrideFontSize: CGFloat? = nil) {
        guard let theme = theme else { return }
        
        textColor = UIColor.fromRGBString(rgbString: theme.textColor)
        font = theme.font.toFont(overrideSize: overrideFontSize)
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI(overrideFontSize: overrideFontSize)
            }
        }
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
