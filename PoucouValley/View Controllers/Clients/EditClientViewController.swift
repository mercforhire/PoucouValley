//
//  EditClientViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-07-12.
//

import UIKit
import PhotosUI
import Mantis

class EditClientViewController: BaseViewController {
    var client: Client!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var avatarImageView: URLImageView!
    @IBOutlet weak var editAvatarButton: UIButton!
    
    @IBOutlet weak var firstNameField: ThemeTextField!
    @IBOutlet weak var lastNameField: ThemeTextField!
    @IBOutlet weak var emailField: ThemeTextField!
    @IBOutlet weak var phoneAreaCodeField: ThemeTextField!
    @IBOutlet weak var phoneField: ThemeTextField!
    
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    
    @IBOutlet weak var birthdayField: ThemeTextField!
    
    @IBOutlet weak var unitNumberField: ThemeTextField!
    @IBOutlet weak var streetNumberField: ThemeTextField!
    @IBOutlet weak var streetNameField: ThemeTextField!
    @IBOutlet weak var cityField: ThemeTextField!
    @IBOutlet weak var provinceField: ThemeTextField!
    @IBOutlet weak var postalField: ThemeTextField!
    @IBOutlet weak var countryField: ThemeTextField!
    
    @IBOutlet weak var companyField: ThemeTextField!
    @IBOutlet weak var jobField: ThemeTextField!
    
    @IBOutlet weak var webField: ThemeTextField!
    @IBOutlet weak var facebookField: ThemeTextField!
    @IBOutlet weak var twitterField: ThemeTextField!
    @IBOutlet weak var instagramField: ThemeTextField!
    
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    @IBOutlet weak var tagsCollectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var notesTextView: UITextView!
    
    var avatar: PVPhoto? {
        didSet {
            if let avatar = avatar, !avatar.thumbnailUrl.isEmpty, !avatar.fullUrl.isEmpty {
                avatarImageView.loadImageFromURL(urlString: avatar.thumbnailUrl)
                editAvatarButton.setImage(UIImage.init(systemName: "minus.circle.fill"), for: .normal)
            } else {
                avatarImageView.image = nil
                editAvatarButton.setImage(UIImage.init(systemName: "plus.circle.fill"), for: .normal)
            }
        }
    }
    var gender: Genders? {
        didSet {
            let highlightColor = themeManager.themeData!.lighterGreen.hexColor
            let unhighlightColor = themeManager.themeData!.lightGray.hexColor
            switch gender {
            case .male:
                maleButton.highlightButton(back: highlightColor,
                                           text: .darkText)
                femaleButton.unhighlightButton(back: unhighlightColor, text: .darkText)
                otherButton.unhighlightButton(back: unhighlightColor, text: .darkText)
            case .female:
                maleButton.unhighlightButton(back: unhighlightColor,
                                           text: .darkText)
                femaleButton.highlightButton(back: highlightColor, text: .darkText)
                otherButton.unhighlightButton(back: unhighlightColor, text: .darkText)
            case .other:
                maleButton.unhighlightButton(back: unhighlightColor, text: .darkText)
                femaleButton.unhighlightButton(back: unhighlightColor, text: .darkText)
                otherButton.highlightButton(back: highlightColor,
                                            text: .darkText)
            default:
                maleButton.unhighlightButton(back: unhighlightColor, text: .darkText)
                femaleButton.unhighlightButton(back: unhighlightColor, text: .darkText)
                otherButton.unhighlightButton(back: unhighlightColor, text: .darkText)
            }
        }
    }
    var birthday: Birthday? {
        didSet {
            if let date = birthday {
                birthdayField.text = "\(date.month) - \(date.day) - \(date.year)"
            } else {
                birthdayField.text = nil
            }
        }
    }

    var tags: [String] = [] {
        didSet {
            resizeCollectionViews()
        }
    }
    var selectedTagIndex: Int?
    
    private let kCellHeight: CGFloat = 37
    private let kItemPadding = 12
    private var imagePicker: ImagePicker!
    private let datePicker = UIDatePicker()
    
    override func setup() {
        super.setup()
        
        gender = nil
        
        avatarImageView.backgroundColor = themeManager.themeData?.defaultBackground.hexColor
        avatarImageView.roundCorners(style: .completely)
        
        datePicker.date = Date().getPastOrFutureDate(years: -18)
        datePicker.datePickerMode = .date
        datePicker.locale = .current
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.sizeToFit()
        datePicker.addTarget(self,
                             action: #selector(datePickerValueChanged(_:)),
                             for: .valueChanged)
        birthdayField.inputView = datePicker
        
        let bubbleLayout = MICollectionViewBubbleLayout()
        bubbleLayout.minimumLineSpacing = 10
        bubbleLayout.minimumInteritemSpacing = 5
        bubbleLayout.delegate = self
        tagsCollectionView.setCollectionViewLayout(bubbleLayout, animated: false)
        
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        notesTextView.text = ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadData()
    }
    
    private func loadData() {
        avatar = client.avatar
        firstNameField.text = client.firstName
        lastNameField.text = client.lastName
        emailField.text = client.email
        phoneAreaCodeField.text = client.contact?.phoneAreaCode
        phoneField.text = client.contact?.phoneNumber
        if let genderString = client.gender {
            gender = Genders(rawValue: genderString)
        }
        birthday = client.birthday
        unitNumberField.text = client.address?.unitNumber
        streetNumberField.text = client.address?.streetNumber
        streetNameField.text = client.address?.street
        cityField.text = client.address?.city
        provinceField.text = client.address?.province
        postalField.text = client.address?.postalCode
        countryField.text = client.address?.country
        companyField.text = client.company
        jobField.text = client.jobTitle
        webField.text = client.contact?.website
        facebookField.text = client.contact?.facebook
        twitterField.text = client.contact?.twitter
        instagramField.text = client.contact?.instagram
        tags = Array(client.hashtags)
        notesTextView.text = client.notes
        
        if let birthday = client.birthday?.date {
            datePicker.date = birthday
        }
    }
    
    @IBAction func editAvatarPressed(_ sender: UIButton) {
        if let photo = avatar,
            !photo.thumbnailUrl.isEmpty,
            !photo.fullUrl.isEmpty {
            
            // delete photo from S3
            FullScreenSpinner().show()
            userManager.deletePhoto(photo: photo) { [weak self] success in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                if success {
                    self.deleteClientAvatar()
                } else {
                    showErrorDialog(error: "Failed to delete photo")
                }
            }
        } else {
            // upload photo to S3
            requestPhotoPermission { [weak self] hasPermission in
                guard let self = self else { return }

                if hasPermission {
                    self.getImageOrVideoFromAlbum(sourceView: sender)
                } else {
                    showErrorDialog(error: "Please enable photo library access for this app in the phone settings.")
                }
            }
        }
    }
    
    private func deleteClientAvatar() {
        api.editClient(clientId: client.identifier,
                       avatar: PVPhoto(thumbnailUrl: "", fullUrl: "")) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.avatar = nil
            default:
                break
            }
        }
    }
    
    private func uploadClientAvatar(photo: PVPhoto) {
        api.editClient(clientId: client.identifier,
                       avatar: photo) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.avatar = photo
            default:
                break
            }
        }
    }
    
    @IBAction func malePressed(_ sender: UIButton) {
        gender = Genders.male
    }
    
    @IBAction func femalePressed(_ sender: UIButton) {
        gender = Genders.female
    }
    
    @IBAction func otherPressed(_ sender: UIButton) {
        gender = Genders.other
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
                              phoneAreaCode: phoneAreaCodeField.text,
                              phoneNumber: phoneField.text,
                              website: webField.text,
                              twitter: twitterField.text,
                              facebook: facebookField.text,
                              instagram: instagramField.text)
        
        FullScreenSpinner().show()
        
        api.editClient(clientId: client.identifier,
                       firstName: firstNameField.text ?? "",
                       lastName: lastNameField.text ?? "",
                       pronoun: gender?.pronoun() ?? "",
                       gender: gender?.rawValue ?? "",
                       birthday: birthday,
                       address: address,
                       contact: contact,
                       avatar: avatar,
                       company: companyField.text ?? "",
                       jobTitle: jobField.text ?? "",
                       hashtags: tags,
                       notes: notesTextView.text ?? "",
                       email: emailField.text ?? "") { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()

            switch result {
            case .success(let response):
                if response.success {
                    self.showClientSavedDialog()
                } else {
                    showErrorDialog(error: response.message)
                }
            case .failure:
                showNetworkErrorDialog()
            }
        }
        
    }
    
    private func showClientSavedDialog() {
        let clientName = "\(firstNameField.text ?? "") \(lastNameField.text ?? "")"
        let ac = UIAlertController(title: "Edit Client", message: "Client \(clientName) has been edited", preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    private func tagPressed() {
        guard let selectedTagIndex = selectedTagIndex else { return }
        
        let tag = tags[selectedTagIndex]
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
        guard let selectedTagIndex = selectedTagIndex, selectedTagIndex < tags.count else { return }
        
        let ac = UIAlertController(title: "Edit tag", message: "Edit tag: \(tags[selectedTagIndex])", preferredStyle: .alert)
        ac.addTextField { [weak self] textfield in
            textfield.keyboardType = .asciiCapable
            textfield.text = self?.tags[selectedTagIndex]
        }
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            if let newTag = ac.textFields![0].text, !newTag.isEmpty {
                self?.tags[selectedTagIndex] = newTag
                self?.tagsCollectionView.reloadData()
            }
        }
        ac.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(cancelAction)
        
        present(ac, animated: true)
    }
    
    private func deleteTag() {
        guard let selectedTagIndex = selectedTagIndex, selectedTagIndex < tags.count else { return }
        
        tags.remove(at: selectedTagIndex)
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
                self?.tags.append(newTag)
                self?.tagsCollectionView.reloadData()
            }
        }
        ac.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(cancelAction)
        
        present(ac, animated: true)
    }
    
    private func uploadPhoto(photo: UIImage) {
        FullScreenSpinner().show()
        
        var uploadedPhoto: PVPhoto?
        let queue = DispatchQueue.global(qos: .default)
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.userManager.uploadPhoto(photo: photo) { pvPhoto in
                if let pvPhoto = pvPhoto {
                    uploadedPhoto = pvPhoto
                } else {
                    showErrorDialog(error: "Failed to upload photo")
                }
                semaphore.signal()
            }
            semaphore.wait()
            
            DispatchQueue.main.async { [weak self] in
                FullScreenSpinner().hide()
                
                if let uploadedPhoto = uploadedPhoto {
                    self?.uploadClientAvatar(photo: uploadedPhoto)
                }
            }
        }
    }
    
    private func validate() -> Bool {
        // first name, last name
        if let firstName = firstNameField.text,
            let lastName = lastNameField.text {
            if !Validator.validate(string: firstName, validation: .isAProperName) {
                showErrorDialog(error: "Please input a proper first name.")
                return false
            }
            
            if !Validator.validate(string: lastName, validation: .containsOneAlpha) {
                showErrorDialog(error: "Please input a proper last name.")
                return false
            }
        } else {
            showErrorDialog(error: "Please input first name and last name at minimal.")
            return false
        }
        
        // email OR phone
        var emailValid = false
        var phoneValid = false
        if let email = emailField.text, !email.isEmpty {
            if Validator.validate(string: email, validation: .email) {
                emailValid = true
            } else {
                showErrorDialog(error: "Please input a proper email.")
                return false
            }
        }
        
        if let areaCode = phoneAreaCodeField.text, !areaCode.isEmpty, let phone = phoneField.text, !phone.isEmpty {
            if Validator.validate(string: phone, validation: .containsOneNumber) {
                phoneValid = true
            } else {
                showErrorDialog(error: "Please input a proper phone number.")
                return false
            }
        }
        
        if !emailValid && !phoneValid {
            showErrorDialog(error: "Please input email or phone at minimal")
            return false
        }
        
        return true
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: sender.date)
        if let day = components.day, let month = components.month, let year = components.year {
            birthday = Birthday(day: day, month: month, year: year)
        }
    }
    
    override func cropViewControllerDidEndResize(_ cropViewController: CropViewController, original: UIImage, cropInfo: CropInfo) {
        dismiss(animated: true, completion: { [weak self] in
            self?.uploadPhoto(photo: original)
        })
    }
    
    override func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        dismiss(animated: true, completion: { [weak self] in
            self?.uploadPhoto(photo: cropped)
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

extension EditClientViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < tags.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MIBubbleCollectionViewCell", for: indexPath) as! MIBubbleCollectionViewCell
            let keyword = tags[indexPath.row]
            cell.lblTitle.text = keyword
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCell", for: indexPath) as! SimpleImageCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < tags.count {
            selectedTagIndex = indexPath.row
            tagPressed()
        } else {
            selectedTagIndex = nil
            showAddTagDialog()
        }
    }
}

extension EditClientViewController: MICollectionViewBubbleLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, itemSizeAt indexPath: NSIndexPath) -> CGSize {
        if indexPath.row < tags.count {
            let interest = tags[indexPath.row]
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
