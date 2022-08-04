//
//  URLImageView.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-08.
//

import UIKit
import Kingfisher

enum BlurAmount {
    case none
    case weak
    case strong
}

class URLImageView: UIImageView {
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
        tintColor = themeManager.themeData!.textLabel.hexColor
        
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
    
    func loadImageFromURL(urlString: String?, blur: BlurAmount = .none, finishAction: Action? = nil) {
        if let urlString = urlString,
            let url = URL(string: urlString) {
            
            switch blur {
            case .none:
                kf.setImage(with: url, placeholder: nil, options: nil) { result in
                    finishAction?()
                }
            case .weak, .strong:
                let resource = ImageResource(downloadURL: url)
                let processor = BlurImageProcessor(blurRadius: blur == .weak ? 10 : 20)
                kf.setImage(with: resource, placeholder: nil, options: [.processor(processor)]) { _ in
                    finishAction?()
                }
            }
        } else {
            image = nil
        }
    }
    
    func cancelLoading() {
        kf.cancelDownloadTask()
    }
}
