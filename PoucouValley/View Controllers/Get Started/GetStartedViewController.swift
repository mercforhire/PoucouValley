//
//  GetStartedViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-08.
//

import UIKit
import SwiftUI
import RealmSwift

class GetStartedViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: ThemeUIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    
    private var steps: [GetStartedSteps] = [] {
        didSet {
            pageControl.numberOfPages = steps.count
        }
    }
    private var page: Int = 0 {
        didSet {
            guard !steps.isEmpty else { return }
            
            pageControl.currentPage = page
            
            collectionView.scrollToItem(at: IndexPath(row: page, section: 0), at: .left, animated: true)
            
            if page == (steps.count - 1) {
                nextButton.setTitle("Start", for: .normal)
            }
        }
    }
    
    
    override func setup() {
        super.setup()
        
        navigationController?.navigationBar.isHidden = true
        page = 0
        
        
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if appSettings.isGetStartedViewed() {
            goToNext()
        } else {
            loadData()
        }
    }
    
    func loadData() {
        FullScreenSpinner().show()
        
        api.fetchGetStartedSteps { [weak self] result in
            FullScreenSpinner().hide()
            
            switch result {
            case .success(let result):
                self?.steps = Array(result.data)
                self?.collectionView.reloadData()
            case .failure:
                showNetworkErrorDialog()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.reloadData()
        pageControl.transform = CGAffineTransform(scaleX: 2, y: 2)
    }

    @IBAction func nextPressed(_ sender: UIButton) {
        if page == (steps.count - 1) {
            appSettings.setGetStartedViewed(viewed: true)
            goToNext()
        } else {
            page = page + 1
        }
    }
    
    private func goToNext() {
        let vc = StoryboardManager.loadViewController(storyboard: "Login", viewControllerId: "LoginHomeViewController") as! LoginHomeViewController
        navigationController?.pushViewController(vc, animated: false)
    }
}

extension GetStartedViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return steps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GetStartedCell", for: indexPath) as! GetStartedCell
        
        let step = steps[indexPath.row]
        cell.config(data: step)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
