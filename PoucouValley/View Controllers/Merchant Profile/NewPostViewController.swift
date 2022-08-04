//
//  NewPostViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-02.
//

import UIKit

class NewPostViewController: BaseViewController {

    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    @IBOutlet weak var titleField: ThemeTextField!
    @IBOutlet weak var descriptionTextView: ThemeRoundedBorderedTextView!
    
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    @IBOutlet weak var tagsCollectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var priceField: ThemeTextField!
    @IBOutlet weak var discountedPriceField: ThemeTextField!
    
    @IBOutlet weak var postButton: ThemeRoundedGreenBlackTextButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
