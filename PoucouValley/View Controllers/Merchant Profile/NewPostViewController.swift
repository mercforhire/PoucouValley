//
//  NewPostViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-02.
//

import UIKit
import PhotosUI
import Mantis

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
    
    private var photos: [UIImage] = [] {
        didSet {
            photoCollectionView.reloadData()
        }
    }
    private var hashtags: [String]? {
        didSet {
            tagsCollectionView.reloadData()
            resizeCollectionViews()
        }
    }
    private var selectedTagIndex: Int?
    
    private let kCellHeight: CGFloat = 37
    private let kItemPadding = 12
    private var imagePicker: ImagePicker!
    
    override func setup() {
        super.setup()
        
        let bubbleLayout = MICollectionViewBubbleLayout()
        bubbleLayout.minimumLineSpacing = 10
        bubbleLayout.minimumInteritemSpacing = 5
        bubbleLayout.delegate = self
        tagsCollectionView.setCollectionViewLayout(bubbleLayout, animated: false)
        
        imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if userManager.user?.merchant == nil {
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func deletePhotoPressed(_ sender: UIButton) {
        guard sender.tag < photos.count else { return }
        
        photos.remove(at: sender.tag)
    }
    
    @IBAction func savePressed(_ sender: UIButton) {
        guard validate() else { return }
        
        FullScreenSpinner().show()
        
        var isSuccess: Bool = true
        let queue = DispatchQueue.global(qos: .default)
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            var photos: [PVPhoto] = []
            
            self.userManager.uploadPhotos(photos: self.photos) { uploadedPhotos, failedImages in
                if !failedImages.isEmpty {
                    isSuccess = false
                } else {
                    photos = uploadedPhotos
                }
                semaphore.signal()
            }
            semaphore.wait()
            
            guard isSuccess else {
                DispatchQueue.main.async {
                    FullScreenSpinner().hide()
                    showErrorDialog(error: "Error uploading photos, add new post failed.")
                }
                return
            }
            
            self.api.addPlan(title: self.titleField.text!,
                             description: self.descriptionTextView.text,
                             photos: photos,
                             price: self.priceField.text?.double,
                             discountedPrice: self.discountedPriceField.text?.double,
                             hashtags: self.hashtags) { result in
                switch result {
                case .success(let response):
                    if !response.success {
                        isSuccess = false
                        showErrorDialog(error: response.message)
                    }
                case .failure:
                    isSuccess = false
                    showNetworkErrorDialog()
                }
            }
            
            DispatchQueue.main.async {
                FullScreenSpinner().hide()
                
                if isSuccess {
                    self.showPostSavedDialog()
                }
            }
        }
    }
    
    private func showPostSavedDialog() {
        let ac = UIAlertController(title: "New post", message: "New post has been saved", preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    private func tagPressed() {
        guard let selectedTagIndex = selectedTagIndex, let tag = hashtags?[selectedTagIndex] else { return }
        
        let ac = UIAlertController(title: nil, message: "Tag: \(tag)", preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "Edit", style: .default) { [weak self] _ in
            self?.showEditTagDialog()
        }
        ac.addAction(action1)
        
        let action2 = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteTag()
        }
        ac.addAction(action2)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    private func showEditTagDialog() {
        guard let selectedTagIndex = selectedTagIndex,
              selectedTagIndex < (hashtags?.count ?? 0),
              let tag = hashtags?[selectedTagIndex] else { return }
        
        let ac = UIAlertController(title: "Edit tag", message: "Edit tag: \(tag)", preferredStyle: .alert)
        ac.addTextField { [weak self] textfield in
            textfield.keyboardType = .asciiCapable
            textfield.text = self?.hashtags?[selectedTagIndex]
        }
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            if let newTag = ac.textFields![0].text, !newTag.isEmpty {
                self?.hashtags?[selectedTagIndex] = newTag
            }
        }
        ac.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(cancelAction)
        
        present(ac, animated: true)
    }
    
    private func deleteTag() {
        guard let selectedTagIndex = selectedTagIndex, selectedTagIndex < (hashtags?.count ?? 0) else { return }
        
        hashtags?.remove(at: selectedTagIndex)
    }
    
    private func showAddTagDialog() {
        let ac = UIAlertController(title: "Add tag", message: "Enter new tag:", preferredStyle: .alert)
        ac.addTextField { textfield in
            textfield.keyboardType = .asciiCapable
            textfield.placeholder = "New tag"
        }
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            if let newTag = ac.textFields![0].text, !newTag.isEmpty {
                if self?.hashtags == nil {
                    self?.hashtags = []
                }
                self?.hashtags?.append(newTag)
            }
        }
        ac.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(cancelAction)
        
        present(ac, animated: true)
    }
    
    private func uploadPhoto(image: UIImage) {
        photos.append(image)
    }
    
    private func validate() -> Bool {
        if let titleField = titleField.text, !titleField.isEmpty {
            
        } else {
            showErrorDialog(error: "Please input a title")
            return false
        }
        
        if let description = descriptionTextView.text, !description.isEmpty {
            
        } else {
            showErrorDialog(error: "Please input a description")
            return false
        }
        
        if photos.isEmpty {
            showErrorDialog(error: "Please upload a photo")
            return false
        }
        
        return true
    }
    
    override func cropViewControllerDidEndResize(_ cropViewController: CropViewController, original: UIImage, cropInfo: CropInfo) {
        dismiss(animated: true, completion: { [weak self] in
            self?.uploadPhoto(image: original)
        })
    }
    
    override func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        dismiss(animated: true, completion: { [weak self] in
            self?.uploadPhoto(image: cropped)
        })
    }
    
    override func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        dismiss(animated: true)
    }
    
    private func resizeCollectionViews() {
        tagsCollectionViewHeight.constant = max(100, tagsCollectionView.contentSize.height) + 34 + CGFloat(kItemPadding)
        stackView.layoutIfNeeded()
    }
}

extension NewPostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == photoCollectionView {
            return photos.count + 1
        } else if collectionView == tagsCollectionView {
            return (hashtags?.count ?? 0) + 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == photoCollectionView {
            if indexPath.row < photos.count {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! URLImageTopRightButtonCell
                let photo = photos[indexPath.row]
                cell.imageView.image = photo
                cell.button.tag = indexPath.row
                cell.button.addTarget(self, action: #selector(deletePhotoPressed), for: .touchUpInside)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCell", for: indexPath)
                return cell
            }
        } else if collectionView == tagsCollectionView {
            if indexPath.row < (hashtags?.count ?? 0) {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MIBubbleCollectionViewCell", for: indexPath) as! MIBubbleCollectionViewCell
                let keyword = hashtags?[indexPath.row]
                cell.lblTitle.text = keyword
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCell", for: indexPath) as! SimpleImageCell
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == photoCollectionView {
            if indexPath.row < photos.count {
                return
            } else {
                // upload photo to S3
                requestPhotoPermission { [weak self] hasPermission in
                    guard let self = self else { return }

                    if hasPermission {
                        self.getImageOrVideoFromAlbum(sourceView: collectionView)
                    } else {
                        showErrorDialog(error: "Please enable photo library access for this app in the phone settings.")
                    }
                }
            }
        } else if collectionView == tagsCollectionView {
            if indexPath.row < (hashtags?.count ?? 0) {
                selectedTagIndex = indexPath.row
                tagPressed()
            } else {
                selectedTagIndex = nil
                showAddTagDialog()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == photoCollectionView {
            return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
        }
        
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == photoCollectionView {
            return 10.0
        }
        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

extension NewPostViewController: MICollectionViewBubbleLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, itemSizeAt indexPath: NSIndexPath) -> CGSize {
        if indexPath.row < (hashtags?.count ?? 0), let tag = hashtags?[indexPath.row] {
            var size = tag.size(withAttributes: [NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 17.0)!])
            size.width = CGFloat(ceilf(Float(size.width + CGFloat(kItemPadding * 2))))
            size.height = kCellHeight
            
            //...Checking if item width is greater than collection view width then set item width == collection view width.
            if size.width > collectionView.frame.size.width {
                size.width = collectionView.frame.size.width
            }
            
            return size
        } else {
            return CGSize(width: kCellHeight, height: kCellHeight)
        }
    }
}

extension NewPostViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        guard collectionView == photoCollectionView else {
            return []
        }
        
        if indexPath.row < photos.count {
            let photoId = "\(photos[indexPath.row].hashValue)"
            let item = NSItemProvider(object: photoId as NSItemProviderWriting)
            let dragItem = UIDragItem(itemProvider: item)
            return [dragItem]
        }
        
        return []
    }
}

extension NewPostViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        guard collectionView == photoCollectionView else {
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        guard collectionView == photoCollectionView else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
        
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard collectionView == photoCollectionView else {
            return
        }
        
        guard let destinationIndexPath = coordinator.destinationIndexPath,
              destinationIndexPath.row < photos.count else {
            return
        }
        
        coordinator.items.forEach { dropItem in
            guard let sourceIndexPath = dropItem.sourceIndexPath else {
                return
            }
            
            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            }, completion: { [weak self] _ in
                coordinator.drop(dropItem.dragItem, toItemAt: destinationIndexPath)
                self?.photos.swapAt(sourceIndexPath.row, destinationIndexPath.row)
            })
        }
    }
}
