//
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-05.
//

import UIKit

protocol PictureTextDialogDelegate: class {
    func dismissedDialog(dialog: PictureTextDialog)
}

struct PictureTextDialogConfig {
    var image: UIImage?
    var primaryLabel: String = ""
    var secondLabel: String = ""
    
    init(image: UIImage?,
         primaryLabel: String,
         secondLabel: String) {
        self.image = image
        self.primaryLabel = primaryLabel
        self.secondLabel = secondLabel
    }
}

class PictureTextDialog: UIView {
    // MARK: - Constants
    private let animationInterval: Double = 0.45
    private let edgeMargin: CGFloat = 10.6
    
    // MARK: - IBOutlets
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var tutorialContainerView: UIView!
    @IBOutlet private var dimBackground: UIView!
    @IBOutlet weak var container1: UIView!
    @IBOutlet weak var titleLabel: ThemeBlackTextLabel!
    @IBOutlet weak var subLabel: ThemeGreyLabel!
    
    // MARK: - Variables
    weak var delegate: PictureTextDialogDelegate?
    
    private var showDimOverlay: Bool = false
    // sometimes adding tutorial view breaks autolayout constraints. In this case, add tutorial view as a subview of UI window instead
    private var overUIWindow: Bool = false
    private var config: PictureTextDialogConfig?
    
    private func setupUI() {
        Bundle.main.loadNibNamed("TwoChoicesDialog", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.roundCorners()
        
        dimBackground.alpha = 0
        dimBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hide)))
        
        tutorialContainerView.alpha = 0
        tutorialContainerView.roundCorners(style: .large)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        frame.size.height = UIScreen.main.bounds.size.height
        frame.size.width = UIScreen.main.bounds.size.width
    }
    
    // MARK: - Public
    func configure(config: PictureTextDialogConfig,
                   showDimOverlay: Bool = false,
                   overUIWindow: Bool = false) {
        self.config = config
        self.showDimOverlay = showDimOverlay
        self.overUIWindow = overUIWindow
        titleLabel.text = config.primaryLabel
        subLabel.text = config.secondLabel
    }
    
    func show(inView view: UIView, withDelay milliseconds: Int = 0) {
        if overUIWindow {
            guard let window = UIViewController.window else { return }
            
            window.addSubview(self)
        } else {
            view.addSubview(self)
        }
        
        func animateAndShow() {
            UIView.animate(withDuration: animationInterval) {
                self.showAllViews()
                self.layoutIfNeeded()
            }
        }
        
        if milliseconds == 0 {
            animateAndShow()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(milliseconds), execute: animateAndShow)
        }
    }
    
    @objc func hide() {
        UIView.animate(withDuration: animationInterval,
                       animations: {
                        self.hideAllViews()
                        self.layoutIfNeeded()
        }) { [weak self] _ in
            guard let self = self else { return }
            
            self.removeFromSuperview()
            self.delegate?.dismissedDialog(dialog: self)
        }
    }
    
    // MARK: - Private
    private func hideAllViews() {
        tutorialContainerView.alpha = 0
        if showDimOverlay {
            dimBackground.alpha = 0
        }
    }
    
    private func showAllViews() {
        tutorialContainerView.alpha = 1
        if showDimOverlay {
            dimBackground.alpha = 1
        }
    }
    
    @IBAction func closePress(_ sender: UIButton) {
        hide()
    }
}
