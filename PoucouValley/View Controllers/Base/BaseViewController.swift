//
//  BaseViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-09.
//

import UIKit
import PhotosUI
import Mantis

class BaseViewController: UIViewController, ImagePickerDelegate, CropViewControllerDelegate {
    var api: PoucouAPI {
        return PoucouAPI.shared
    }
    var appSettings: AppSettingsManager {
        return AppSettingsManager.shared
    }
    var userManager: UserManager {
        return UserManager.shared
    }
    var currentUser: UserDetails {
        return UserManager.shared.user!
    }
    private var imagePicker: ImagePicker?
    
    private var observer: NSObjectProtocol?
   
    static let tableRefreshDelay: TimeInterval = 0.35
    var mainTableView: UITableView?
    var tableRefreshTimer: Timer?
    
    func setup() {
        // override
        setupTheme()
    }
    
    func setupTheme() {
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    @IBAction func backPressed(_ sender: UIBarButtonItem? = nil) {
        if let navigationController = navigationController {
            if navigationController.viewControllers.count > 1 {
                navigationController.popViewController(animated: true)
            } else {
                navigationController.dismiss(animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func setupImagePicker() {
        guard imagePicker == nil else { return }
        
        imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    
    func requestPhotoPermission(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    completion(true)
                default:
                    completion(false)
                }
            }
        }
    }
    
    func getImageOrVideoFromAlbum( sourceView: UIView) {
        if imagePicker == nil {
            setupImagePicker()
        }
        
        self.imagePicker?.present(from: sourceView)
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
    
    private func showMantis(image: UIImage) {
        var config = Mantis.Config()
        config.cropToolbarConfig.toolbarButtonOptions = [.clockwiseRotate, .reset, .ratio, .alterCropper90Degree];
        
        let cropViewController = Mantis.cropViewController(image: image,
                                                           config: config)
        cropViewController.modalPresentationStyle = .fullScreen
        cropViewController.delegate = self
        present(cropViewController, animated: true)
    }
    
    func refreshTableCellHeights(tableView: UITableView) {
        mainTableView = tableView
        
        if let timer = tableRefreshTimer {
            timer.invalidate()
            tableRefreshTimer = nil
        }
        tableRefreshTimer = Timer.scheduledTimer(timeInterval: BaseViewController.tableRefreshDelay,
                                                 target: self,
                                                 selector: #selector(tableRefreshTimerFired),
                                                 userInfo: nil,
                                                 repeats: false)
    }
    
    @objc func tableRefreshTimerFired() {
        tableRefreshTimer = nil
        
        mainTableView?.beginUpdates()
        mainTableView?.endUpdates()
    }
    
    // ImagePickerDelegate
    
    func didSelectImage(image: UIImage?) {
        guard let image = image else {
            return
        }
        
        showMantis(image: image)
    }
    
    func didSelectVideo(video: PHAsset?) {
        // override
    }
    
    // CropViewControllerDelegate
    
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {
        // override
    }
    
    func cropViewControllerDidBeginResize(_ cropViewController: CropViewController) {
        // override
    }
    
    func cropViewControllerDidEndResize(_ cropViewController: CropViewController, original: UIImage, cropInfo: CropInfo) {
        // override
    }
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        // override
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        // override
    }
}
