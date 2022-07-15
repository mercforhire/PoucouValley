//
//  MyProfileViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-10.
//

import UIKit
import Mantis

class MyProfileViewController: BaseViewController {

    private enum TableRows: Int {
        case completeProfile
        case sectionTitle
        case giftCard
    }
    
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var avatarContainer: UIView!
    @IBOutlet weak var avatarImageView: URLImageView!
    @IBOutlet weak var nameLabel: ThemeBlackTextLabel!
    @IBOutlet weak var coinsLabel: ThemeBlackTextLabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var goals: [Goal]?
    private var completedGoals: [Goal]?
    private var giftcards: [UnsplashPhoto]?
    private var rows: [TableRows] {
        var rows: [TableRows] = []
        if let goals = goals, let completedGoals = completedGoals {
            if goals.count > completedGoals.count {
                rows.append(.completeProfile)
            }
        }
        rows.append(.sectionTitle)
        for _ in giftcards ?? [] {
            rows.append(.giftCard)
        }
        return rows
    }
    
    override func setup() {
        super.setup()
        navigationController?.navigationBar.isHidden = true
        headerContainer.roundCorners(style: .small)
        avatarContainer.roundCorners(style: .completely)
        avatarImageView.roundCorners(style: .completely)
        avatarImageView.backgroundColor = themeManager.themeData!.lighterGreen.hexColor
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.lighterGreen.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchContents()
    }
    
    @IBAction func avatarPressed(_ sender: UIButton) {
        // pick photo, upload, update profile
        requestPhotoPermission { [weak self] hasPermission in
            guard let self = self else { return }

            if hasPermission {
                self.getImageOrVideoFromAlbum(sourceView: sender)
            } else {
                showErrorDialog(error: "Please enable photo library access for this app in the phone settings.")
            }
        }
    }
    
    private func fetchContents(complete: ((Bool) -> Void)? = nil) {
        var isSuccess: Bool = true
        let queue = DispatchQueue.global(qos: .default)
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.userManager.fetchUser { success in
                isSuccess = success
                semaphore.signal()
            }
            semaphore.wait()
            
            self.api.fetchGoals { [weak self] result in
                switch result {
                case .success(let response):
                    self?.goals = Array(response.data).filter({ goal in
                        return Goal.supportGoals().contains(goal.goal)
                    })
                case .failure:
                    isSuccess = false
                }
                semaphore.signal()
            }
            semaphore.wait()
            
            self.api.fetchCompletedGoals { [weak self] result in
                switch result {
                case .success(let response):
                    self?.completedGoals = Array(response.data).filter({ goal in
                        return Goal.supportGoals().contains(goal.goal)
                    })
                case .failure:
                    isSuccess = false
                }
                semaphore.signal()
            }
            semaphore.wait()
            
            self.api.getGiftcards { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    self.giftcards = response
                case .failure:
                    isSuccess = false
                }
                semaphore.signal()
            }
            semaphore.wait()
            
            DispatchQueue.main.async { [weak self] in
                self?.refreshProfileHeader()
                self?.tableView.reloadData()
                complete?(isSuccess)
            }
        }
    }
    
    private func refreshProfileHeader() {
        if let avatar = currentUser.cardholder?.avatar {
            avatarImageView.loadImageFromURL(urlString: avatar.thumbnailUrl)
        }
    }
    
    private func uploadPhoto(photo: UIImage) {
        FullScreenSpinner().show()
        
        var isSuccess: Bool = true
        var uploadedPhoto: PVPhoto?
        let queue = DispatchQueue.global(qos: .default)
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.userManager.uploadPhoto(photo: photo) { pvPhoto in
                if let pvPhoto = pvPhoto {
                    uploadedPhoto = pvPhoto
                } else {
                    isSuccess = false
                    showErrorDialog(error: "Failed to upload photo")
                }
                semaphore.signal()
            }
            semaphore.wait()
            
            guard let uploadedPhoto = uploadedPhoto else {
                DispatchQueue.main.async {
                    FullScreenSpinner().hide()
                }
                return
            }
            
            self.userManager.updateCardholderInfo(avatar: uploadedPhoto) { result in
                switch result {
                case .failure:
                    isSuccess = false
                default:
                    break
                }
                
                semaphore.signal()
            }
            semaphore.wait()
            
            DispatchQueue.main.async { [weak self] in
                FullScreenSpinner().hide()
                
                if isSuccess {
                    self?.refreshProfileHeader()
                }
            }
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
}

extension MyProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.row]
        
        switch row {
        case .completeProfile:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CompleteProfileCell", for: indexPath) as? CompleteProfileCell else {
                return CompleteProfileCell()
            }
            
            cell.config(all: goals ?? [], completed: completedGoals ?? [])
            return cell
        case .giftCard:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "GiftTableViewCell", for: indexPath) as? GiftTableViewCell,
                    let giftcard = giftcards?[indexPath.row - (rows.firstIndex(of: .giftCard) ?? 0)] else {
                return GiftTableViewCell()
            }
            
            cell.config(unsplashPhoto: giftcard)
            return cell
        case .sectionTitle:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "GiftTableViewCell", for: indexPath) as? GiftTableViewCell,
                    let giftcard = giftcards?[indexPath.row - (rows.firstIndex(of: .giftCard) ?? 0)] else {
                return GiftTableViewCell()
            }
            
            cell.config(unsplashPhoto: giftcard)
            return cell
        }
    }
}
