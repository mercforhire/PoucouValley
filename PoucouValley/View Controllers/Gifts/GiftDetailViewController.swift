//
//  GiftDetailViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-05.
//

import UIKit

class GiftDetailViewController: BaseViewController {
    var gift: Gift!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: ThemeUIPageControl!
    @IBOutlet weak var coinsLabel: ThemeGreenTextLabel!
    @IBOutlet weak var titleLabel: ThemeBlackTextLabel!
    @IBOutlet weak var shortDesLabel: ThemeDarkLabel!
    @IBOutlet weak var longDesLabel: ThemeDarkLabel!
    @IBOutlet weak var redeemButton: ThemeRoundedGreenBlackTextButton!
    
    var photos: [PVPhoto] = [] {
        didSet {
            pageControl.numberOfPages = photos.count
            collectionView.reloadData()
            
            if !photos.isEmpty {
                collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    override func setup() {
        super.setup()
        
        coinsLabel.text = "-- coins"
        titleLabel.text = ""
        shortDesLabel.text = ""
        longDesLabel.text = ""
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadData()
    }
    
    private func loadData() {
        coinsLabel.text = "\(gift.costInCoins) coins"
        titleLabel.text = gift.name
        shortDesLabel.text = gift.itemDescription
        longDesLabel.text = gift.itemDescription2
    }
    
    @IBAction func redeemPressed(_ sender: ThemeRoundedGreenBlackTextButton) {
        FullScreenSpinner().show()
        
        api.redeemGift(gift: gift) { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()

            switch result {
            case .success(let response):
                if response.success {
                    self.showRedeemedSuccessDialog()
                } else {
                    showErrorDialog(error: response.message)
                }
            case .failure:
                showNetworkErrorDialog()
            }
        }
    }

    private func showRedeemedSuccessDialog() {
        let dialog = RedeemConfirmationDialog()
        dialog.configure(showDimOverlay: true, overUIWindow: true)
        dialog.delegate = self
        dialog.show(inView: view, withDelay: 100)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let centerCell = collectionView.centerMostCell else { return }
        
        let indexPath = collectionView.indexPath(for: centerCell)
        pageControl.currentPage = indexPath?.row ?? 0
    }
}

extension GiftDetailViewController: RedeemConfirmationDialogDelegate {
    func buttonSelected(index: Int, dialog: RedeemConfirmationDialog) {
        
    }
    
    func dismissedDialog(dialog: RedeemConfirmationDialog) {
        navigationController?.popViewController(animated: true)
    }
}

extension GiftDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! SimpleURLImageCell
        
        let photo = photos[indexPath.row]
        cell.imageView.loadImageFromURL(urlString: photo.fullUrl)
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
