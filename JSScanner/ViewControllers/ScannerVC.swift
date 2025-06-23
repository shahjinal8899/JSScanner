//
//  ScannerVC.swift
//  JSScanner
//
//  Created by Jinal Shah on 19/03/22.
//

import UIKit
import AVFoundation
import Vision
import VisionKit

class ScannerVC: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var btnUpload: UIButton!
    @IBOutlet weak var btnTorch: UIButton!
    @IBOutlet weak var vwPreview: QRCodeReaderView! {
        didSet {
            vwPreview.setupComponents(showCancelButton: false, showSwitchCameraButton: false, showTorchButton: false, showOverlayView: true, reader: reader)
        }
    }
    
    //MARK: - Variables
    var reader: QRCodeReader = QRCodeReader()
    var imagePicker = UIImagePickerController()
    var strDetectedCode = ""
    
    //MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.btnUpload.layer.cornerRadius = 20
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Setup Preview for camera
        self.scanInPreviewView()
    }
    
    //MARK: - Button Action Methods
    @IBAction func btnTorch_clk(_ sender: Any) {
        self.btnTorch.isSelected = !self.btnTorch.isSelected
        self.reader.toggleTorch()
    }
    
    @IBAction func btnUpload(_ sender: Any) {
        self.openGallary()
    }
    
    //MARK: - Detect QR Code Method
    func detectQRCode(_ image: UIImage?) -> [CIFeature]? {
        if let image = image, let ciImage = CIImage.init(image: image){
            var options: [String: Any]
            let context = CIContext()
            options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
            if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)) {
                options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
            } else {
                options = [CIDetectorImageOrientation: 1]
            }
            let features = qrDetector?.features(in: ciImage, options: options)
            return features
        }
        return nil
    }
    
    //MARK: - Detect Barcode Method
    func detectBarcode(_ image: UIImage) {
        guard let cgImage = image.cgImage else {
            //Show Alert
            self.showAlert(withTitle: "CGImage error", withMsg: "Unable to convert UIImage to CGImage")
            print("Unable to convert UIImage to CGImage")
            return
        }
        
        // Define barcode request
        let request = VNDetectBarcodesRequest { (request, error) in
            if let error = error {
                print("Barcode detection error: \(error)")
                //Show Alert
                self.showAlert(withTitle: "Barcode detection error", withMsg: error.localizedDescription)
                
                return
            }
            
            guard let results = request.results as? [VNBarcodeObservation], !results.isEmpty else {
                print("No barcode detected")
                //Show Alert
                self.showAlert(withTitle: "Scan Result", withMsg: "No barcode detected")
                
                return
            }
            
            for barcode in results {
                if let payload = barcode.payloadStringValue {
                    self.strDetectedCode = payload
                    print("Barcode found: \(payload)")
                    
                    //Show Alert
                    self.showAlert(withTitle: "Scan Result", withMsg: self.strDetectedCode)
                }
            }
        }
        request.symbologies = [.qr, .code128, .ean13, .ean8, .code39, .upce, .pdf417, .code39Checksum, .code39FullASCII, .code39FullASCIIChecksum, .code93, .aztec, .itf14, .i2of5, .dataMatrix]
        
        // Setup image request handler
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // Perform request
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                //Show Alert
                self.showAlert(withTitle: "Failed to perform barcode request", withMsg: error.localizedDescription)
                
                print("Failed to perform barcode request: \(error)")
            }
        }
    }
    
    //MARK: - Other Methods
    func showAlert(withTitle: String, withMsg: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: withTitle, message: withMsg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {_ in
                self.reader.startScanning()
            }))
            self.present(alert, animated: true, completion: nil)
        }
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

//MARK: - QRCodeReader Methods
extension ScannerVC {
    func scanInPreviewView() {
        guard checkScanPermissions(), !reader.isRunning else { return }
        
        reader.didFindCode = { result in
            //print("metadataType: \(result.metadataType)")
            
            self.strDetectedCode = result.value
            print("Scan code: \(self.strDetectedCode)")
            
            //Show Alert
            self.showAlert(withTitle: "Scan Result", withMsg: self.strDetectedCode)
        }
        reader.startScanning()
    }
    
    func resetScanner() {
        self.reader.startScanning()
    }
    
    private func checkScanPermissions() -> Bool {
        do {
            return try QRCodeReader.supportsMetadataObjectTypes()
            
        } catch let error as NSError {
            let alert: UIAlertController
            
            switch error.code {
            case -11852:
                alert = UIAlertController(title: "Error", message: "This app is not authorized to use Rear Camera.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
                    DispatchQueue.main.async {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                        }
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            default:
                alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            }
            present(alert, animated: true, completion: nil)
            
            return false
        }
    }
}

//MARK: - UIImagePickerController Delegate Methods
extension ScannerVC: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func openGallary() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .currentContext
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: {
            if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                var isDetected: Bool = false
                
                //Detect QR Code
                if let features = self.detectQRCode(pickedImage),
                   !features.isEmpty {
                    for case let row as CIQRCodeFeature in features {
                        self.strDetectedCode = row.messageString ?? "No data found"
                        print("Scan code: \(self.strDetectedCode)")
                        
                        isDetected = true
                        
                        //Show Alert
                        self.showAlert(withTitle: "Scan Result", withMsg: self.strDetectedCode)
                    }
                } else {
                    isDetected = false
                }
                
                if !isDetected {
                    //Detect Barcode
                    self.detectBarcode(pickedImage)
                }
            }
        })
    }
}

//MARK: - UIImage Extension
extension UIImage {
    var cgImageOrientation : CGImagePropertyOrientation {
        switch imageOrientation {
        case .up: return .up
        case .upMirrored: return .upMirrored
        case .down: return .down
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .right: return .right
        case .rightMirrored: return .rightMirrored
        case .left: return .left
        default: return.up
        }
    }
}
