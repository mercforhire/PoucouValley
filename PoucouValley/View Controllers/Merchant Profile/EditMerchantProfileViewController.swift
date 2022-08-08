//
//  EditMerchantProfileViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-02.
//

import UIKit
import PhotosUI
import Mantis

class EditMerchantProfileViewController: BaseViewController {

    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var logoContainer: UIView!
    @IBOutlet weak var logoImageView: URLImageView!
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    @IBOutlet weak var nameField: ThemeTextField!
    @IBOutlet weak var categoryField: ThemeTextField!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    @IBOutlet weak var tagsCollectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var areaCodeField: ThemeTextField!
    @IBOutlet weak var phoneField: ThemeTextField!
    @IBOutlet weak var webField: ThemeTextField!
    @IBOutlet weak var facebookField: ThemeTextField!
    @IBOutlet weak var twitterField: ThemeTextField!
    @IBOutlet weak var instagramField: ThemeTextField!
    
    @IBOutlet weak var unitNumberField: ThemeTextField!
    @IBOutlet weak var streetNumberField: ThemeTextField!
    @IBOutlet weak var streetNameField: ThemeTextField!
    @IBOutlet weak var cityField: ThemeTextField!
    @IBOutlet weak var provinceField: ThemeTextField!
    @IBOutlet weak var postalField: ThemeTextField!
    @IBOutlet weak var countryField: ThemeTextField!

    private var merchant: Merchant {
        return userManager.user!.merchant!
    }
    
    private var logo: PVPhoto? {
        didSet {
            if let logo = logo {
                logoImageView.loadImageFromURL(urlString: logo.thumbnailUrl)
            } else {
                logoImageView.image = UIImage(systemName: "camera")
            }
        }
    }
    
    private var photos: [PVPhoto] = [] {
        didSet {
            photoCollectionView.reloadData()
        }
    }
    
    private var selectedType: BusinessCategories? {
        didSet {
            categoryField.text = selectedType?.rawValue
        }
    }
    
    private var hashtags: [String] = [] {
        didSet {
            tagsCollectionView.reloadData()
        }
    }
    private var selectedTagIndex: Int?
    
    private let kCellHeight: CGFloat = 37
    private let kItemPadding = 12
    private var imagePicker: ImagePicker!
    private let businessTypePickerView = UIPickerView()
    
    private var uploadingLogo = false
    
    override func setup() {
        super.setup()
        
        logoContainer.roundCorners(style: .completely)
        logoImageView.roundCorners(style: .completely)
        logoImageView.backgroundColor = themeManager.themeData!.lighterGreen.hexColor
        
        let bubbleLayout = MICollectionViewBubbleLayout()
        bubbleLayout.minimumLineSpacing = 10
        bubbleLayout.minimumInteritemSpacing = 5
        bubbleLayout.delegate = self
        tagsCollectionView.setCollectionViewLayout(bubbleLayout, animated: false)
        
        businessTypePickerView.delegate = self
        businessTypePickerView.dataSource = self
        categoryField.inputView = businessTypePickerView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if userManager.user?.merchant == nil {
            navigationController?.popViewController(animated: true)
        }
        
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    private func fetchData(complete: ((Bool) -> Void)? = nil) {
        userManager.fetchUser { [weak self] success in
            self?.refreshViewController()
        }
    }
    
    private func refreshViewController() {
        logo = merchant.logo
        photos = Array(merchant.photos)
        hashtags = Array(merchant.hashtags)
        
        nameField.text = merchant.name
        selectedType = merchant.category
        
        descriptionTextView.text = merchant.merchantDescription
        
        areaCodeField.text = merchant.contact?.phoneAreaCode
        phoneField.text = merchant.contact?.phoneNumber
        webField.text = merchant.contact?.website
        facebookField.text = merchant.contact?.facebook
        twitterField.text = merchant.contact?.twitter
        instagramField.text = merchant.contact?.instagram
        
        unitNumberField.text = merchant.address?.unitNumber
        streetNumberField.text = merchant.address?.streetNumber
        streetNameField.text = merchant.address?.street
        cityField.text = merchant.address?.city
        provinceField.text = merchant.address?.province
        postalField.text = merchant.address?.postalCode
        countryField.text = merchant.address?.country
    }

    @IBAction func logoPressed(_ sender: UIButton) {
        requestPhotoPermission { [weak self] hasPermission in
            guard let self = self else { return }

            if hasPermission {
                self.uploadingLogo = true
                self.getImageOrVideoFromAlbum(sourceView: sender)
            } else {
                showErrorDialog(error: "Please enable photo library access for this app in the phone settings.")
            }
        }
    }
    
    @objc func deletePhotoPressed(_ sender: UIButton) {
        guard sender.tag < photos.count else { return }
        
        if photos.count <= 1 {
            showErrorDialog(error: "Can not delete last photo")
            return
        }
        
        photos.remove(at: sender.tag)
    }
    
    @IBAction func savePressed(_ sender: UIButton) {
        guard validate() else { return }
        
        let address = Address(unitNumber: unitNumberField.text,
                              streetNumber: streetNumberField.text,
                              street: streetNameField.text,
                              city: cityField.text,
                              province: provinceField.text,
                              country: countryField.text,
                              postalCode: postalField.text)
        
        let contact = Contact(email: nil,
                              phoneAreaCode: areaCodeField.text,
                              phoneNumber: phoneField.text,
                              website: webField.text,
                              twitter: twitterField.text,
                              facebook: facebookField.text,
                              instagram: instagramField.text)
        
        let params = UpdateMerchantInfoParams(name: nameField.text,
                                              field: selectedType,
                                              logo: logo,
                                              photos: photos,
                                              contact: contact,
                                              address: address,
                                              cards: nil,
                                              description: descriptionTextView.text,
                                              hashtags: hashtags)
        
        FullScreenSpinner().show()
        
        api.updateMerchantInfo(params: params) { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()

            switch result {
            case .success(let response):
                if response.success {
                    self.showMerchantSavedDialog()
                } else {
                    showErrorDialog(error: response.message)
                }
            case .failure:
                showNetworkErrorDialog()
            }
        }
    }
    
    private func showMerchantSavedDialog() {
        let ac = UIAlertController(title: "Edit merchant", message: "Merchant info has been edited", preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    private func tagPressed() {
        guard let selectedTagIndex = selectedTagIndex else { return }
        
        let tag = hashtags[selectedTagIndex]
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
        guard let selectedTagIndex = selectedTagIndex, selectedTagIndex < hashtags.count else { return }
        
        let ac = UIAlertController(title: "Edit tag", message: "Edit tag: \(hashtags[selectedTagIndex])", preferredStyle: .alert)
        ac.addTextField { [weak self] textfield in
            textfield.keyboardType = .asciiCapable
            textfield.text = self?.hashtags[selectedTagIndex]
        }
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            if let newTag = ac.textFields![0].text, !newTag.isEmpty {
                self?.hashtags[selectedTagIndex] = newTag
                self?.tagsCollectionView.reloadData()
            }
        }
        ac.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(cancelAction)
        
        present(ac, animated: true)
    }
    
    private func deleteTag() {
        guard let selectedTagIndex = selectedTagIndex, selectedTagIndex <         hashtags.count else { return }
        
        hashtags.remove(at: selectedTagIndex)
        tagsCollectionView.reloadData()
    }
    
    private func showAddTagDialog() {
        let ac = UIAlertController(title: "Add tag", message: "Enter new tag:", preferredStyle: .alert)
        ac.addTextField { textfield in
            textfield.keyboardType = .asciiCapable
            textfield.placeholder = "New tag"
        }
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            if let newTag = ac.textFields![0].text, !newTag.isEmpty {
                self?.hashtags.append(newTag)
                self?.tagsCollectionView.reloadData()
            }
        }
        ac.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(cancelAction)
        
        present(ac, animated: true)
    }
    
    private func uploadPhoto(image: UIImage) {
        FullScreenSpinner().show()
        
        userManager.uploadPhoto(photo: image) { [weak self] photo in
            FullScreenSpinner().hide()
            
            guard let self = self else { return }
            
            if let photo = photo {
                if self.uploadingLogo {
                    self.logo = photo
                } else {
                    self.photos.append(photo)
                }
            } else {
                showErrorDialog(error: "Failed to upload photo")
            }
        }
    }
    
    private func validate() -> Bool {
        // first name, last name
        if let name = nameField.text, !name.isEmpty {
            
        } else {
            showErrorDialog(error: "Please input a business name")
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tagsCollectionViewHeight.constant = tagsCollectionView.collectionViewLayout.collectionViewContentSize.height
    }
}

extension EditMerchantProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == businessTypePickerView {
            return BusinessCategories.list().count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == businessTypePickerView {
            return BusinessCategories.list()[row].rawValue
        }
        
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == businessTypePickerView {
            selectedType = BusinessCategories.list()[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Poppins-Regular", size: 19.0)
            pickerLabel?.textAlignment = .center
        }
        if pickerView == businessTypePickerView {
            pickerLabel?.text = BusinessCategories.list()[row].rawValue
        }
        pickerLabel?.textColor = ThemeManager.shared.themeData!.textLabel.hexColor
        return pickerLabel!
    }
}

extension EditMerchantProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == photoCollectionView {
            return photos.count + 1
        } else if collectionView == tagsCollectionView {
            return hashtags.count + 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == photoCollectionView {
            if indexPath.row < photos.count {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! URLImageTopRightButtonCell
                let photo = photos[indexPath.row]
                cell.imageView.loadImageFromURL(urlString: photo.thumbnailUrl)
                cell.imageView.roundCorners(style: .medium)
                cell.button.tag = indexPath.row
                cell.button.addTarget(self, action: #selector(deletePhotoPressed), for: .touchUpInside)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCell", for: indexPath)
                return cell
            }
        } else if collectionView == tagsCollectionView {
            if indexPath.row < hashtags.count {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MIBubbleCollectionViewCell", for: indexPath) as! MIBubbleCollectionViewCell
                let keyword = hashtags[indexPath.row]
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
                        self.uploadingLogo = false
                        self.getImageOrVideoFromAlbum(sourceView: collectionView)
                    } else {
                        showErrorDialog(error: "Please enable photo library access for this app in the phone settings.")
                    }
                }
            }
        } else if collectionView == tagsCollectionView {
            if indexPath.row < hashtags.count {
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

extension EditMerchantProfileViewController: MICollectionViewBubbleLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, itemSizeAt indexPath: NSIndexPath) -> CGSize {
        if indexPath.row < hashtags.count {
            let interest = hashtags[indexPath.row]
            var size = interest.size(withAttributes: [NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 17.0)!])
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

extension EditMerchantProfileViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        guard collectionView == photoCollectionView else {
            return []
        }
        
        if indexPath.row < photos.count {
            let photoId = photos[indexPath.row].thumbnailUrl
            let item = NSItemProvider(object: photoId as NSItemProviderWriting)
            let dragItem = UIDragItem(itemProvider: item)
            return [dragItem]
        }
        
        return []
    }
}

extension EditMerchantProfileViewController: UICollectionViewDropDelegate {
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
