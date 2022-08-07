//
//  ScanClientCardViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-07-20.
//

import UIKit
import MercariQRScanner
import AVFoundation

class ScanClientCardViewController: BaseViewController {
    
    var scannedCardNumber: String? {
        didSet {
            if let _ = scannedCardNumber {
                submitCode()
            }
        }
    }
    @IBOutlet weak private var scannerContainer: UIView!
    
    override func setup() {
        super.setup()
        
        setupQRScanner()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }

    private func setupQRScanner() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupQRScannerView()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async { [weak self] in
                        self?.setupQRScannerView()
                    }
                }
            }
        default:
            showCameraAlert()
        }
    }
    
    private func setupQRScannerView() {
        let qrScannerView = QRScannerView(frame: view.bounds)
        scannerContainer.addSubview(qrScannerView)
        qrScannerView.configure(delegate: self, input: .init(isBlurEffectEnabled: true))
        qrScannerView.startRunning()
    }
    
    private func showCameraAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let alert = UIAlertController(title: "Error", message: "Camera is required to use in this application", preferredStyle: .alert)
            let action = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            alert.addAction(action)
            self?.present(alert, animated: true)
        }
    }
    
    private func submitCode() {
        if let scannedCardNumber = scannedCardNumber, !scannedCardNumber.isEmpty {
            FullScreenSpinner().show()
            
            api.scanCard(cardNumber: scannedCardNumber) { [weak self] result in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                
                switch result {
                case .success(let response):
                    if response.success {
                        self.showCardScannedDialog()
                    } else {
                        showErrorDialog(error: response.message)
                    }
                case .failure:
                    showNetworkErrorDialog()
                }
            }
        }
    }
    
    private func showCardScannedDialog() {
        let dialog = PictureTextDialog()
        let dialogImage = UIImage(named: "creditcard")
        let config = PictureTextDialogConfig(image: dialogImage, primaryLabel: "Poncou card successfully scanned!", secondLabel: "")
        dialog.configure(config: config, showDimOverlay: true, overUIWindow: true)
        dialog.delegate = self
        dialog.show(inView: view, withDelay: 100)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
}

extension ScanClientCardViewController: QRScannerViewDelegate {
    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {
        print(error)
    }

    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {
        print(code)
        if Validator.validate(string: code, validation: .poucouCardNumber) {
            scannedCardNumber = code
        }
    }
}

extension ScanClientCardViewController: PictureTextDialogDelegate {
    func dismissedDialog(dialog: PictureTextDialog) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
