//
//  CardScanViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-25.
//

import UIKit
import MercariQRScanner
import AVFoundation

class CardScanViewController: BaseViewController {

    var scannedCardNumber: String? {
        didSet {
            if let _ = scannedCardNumber {
                performSegue(withIdentifier: "goToEnterPin", sender: self)
            }
        }
    }
    @IBOutlet weak private var scannerContainer: UIView!
    
    override func setup() {
        super.setup()
        navigationController?.navigationBar.isHidden = true
        
        setupQRScanner()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
            showAlert()
        }
    }
    
    private func setupQRScannerView() {
        let qrScannerView = QRScannerView(frame: view.bounds)
        scannerContainer.addSubview(qrScannerView)
        qrScannerView.configure(delegate: self, input: .init(isBlurEffectEnabled: true))
        qrScannerView.startRunning()
    }
    
    private func showAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let alert = UIAlertController(title: "Error", message: "Camera is required to use in this application", preferredStyle: .alert)
            let action = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            alert.addAction(action)
            self?.present(alert, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SignUpEnterPinViewController {
            vc.cardNumber = scannedCardNumber
        }
    }

}

extension CardScanViewController: QRScannerViewDelegate {
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
