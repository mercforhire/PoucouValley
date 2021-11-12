//
//  HorizontalPaginationManager.swift
//  TrueFan
//
//  Created by Abhishek Thapliyal on 15/07/20.
//  Copyright © 2020 TrueFan. All rights reserved.
//

import Foundation
import UIKit

protocol VerticalPaginationManagerDelegate: class {
    func loadMore(completion: @escaping (Bool) -> Void)
}

class VerticalPaginationManager: NSObject {
    private var isLoading = false
    private var isObservingKeyPath: Bool = false
    private var scrollView: UIScrollView!
    private var loaderView: UIView?
    
    var refreshViewColor: UIColor = .white
    var loaderColor: UIColor = .white
    
    weak var delegate: VerticalPaginationManagerDelegate?
    
    init(scrollView: UIScrollView) {
        super.init()
        self.scrollView = scrollView
        self.addScrollViewOffsetObserver()
    }
    
    deinit {
        self.removeScrollViewOffsetObserver()
    }
    
}

extension VerticalPaginationManager {
    
    private func addBottomLoaderControl() {
        let view = UIView()
        view.backgroundColor = self.refreshViewColor
        view.frame.origin = CGPoint(x: 0,
                                    y: self.scrollView.contentSize.height)
        view.frame.size = CGSize(width: self.scrollView.bounds.width,
                                 height: 60)
        let activity = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        activity.color = self.loaderColor
        activity.frame = view.bounds
        activity.startAnimating()
        view.addSubview(activity)
        self.scrollView.contentInset.bottom = view.frame.height
        self.loaderView = view
        self.scrollView.addSubview(view)
    }
    
    func removeLoader() {
        self.loaderView?.removeFromSuperview()
        self.loaderView = nil
    }
    
}

extension VerticalPaginationManager {
    private func addScrollViewOffsetObserver() {
        if self.isObservingKeyPath { return }
        self.scrollView.addObserver(
            self,
            forKeyPath: "contentOffset",
            options: [.new],
            context: nil
        )
        self.isObservingKeyPath = true
    }
    
    private func removeScrollViewOffsetObserver() {
        if self.isObservingKeyPath {
            self.scrollView.removeObserver(self,
                                           forKeyPath: "contentOffset")
        }
        self.isObservingKeyPath = false
    }
    
    override public func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?) {
        guard let object = object as? UIScrollView,
              let keyPath = keyPath,
              let newValue = change?[.newKey] as? CGPoint,
              object == self.scrollView, keyPath == "contentOffset" else { return }
        self.setContentOffSet(newValue)
    }
    
    private func setContentOffSet(_ offset: CGPoint) {
        let offsetY = offset.y
        let contentHeight = self.scrollView.contentSize.height
        let frameHeight = self.scrollView.bounds.size.height
        let diffY = contentHeight - frameHeight
        if contentHeight > frameHeight, offsetY > (diffY + 70) && !self.isLoading {
            self.isLoading = true
            self.addBottomLoaderControl()
            self.delegate?.loadMore { success in
                self.isLoading = false
                self.removeLoader()
            }
        }
    }
}
