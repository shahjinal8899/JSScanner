
import AVFoundation

/**
 This protocol defines delegate methods for objects that implements the `QRCodeReaderDelegate`. The methods of the protocol allow the delegate to be notified when the reader did scan result and or when the user wants to stop to read some QRCodes.
 */
public protocol QRCodeReaderViewControllerDelegate: AnyObject {
    /**
     Tells the delegate that the reader did scan a code.
     
     - parameter reader: A code reader object informing the delegate about the scan result.
     - parameter result: The result of the scan
     */
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult)
    
    /**
     Tells the delegate that the camera was switched by the user
     
     - parameter reader: A code reader object informing the delegate about the scan result.
     - parameter newCaptureDevice: The capture device that was switched to
     */
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput)
    
    /**
     Tells the delegate that the user wants to stop scanning codes.
     
     - parameter reader: A code reader object informing the delegate about the cancellation.
     */
    func readerDidCancel(_ reader: QRCodeReaderViewController)
}

extension QRCodeReaderViewControllerDelegate {
    
    /**
     Default implementation that No-Ops this callBack
     
     - parameter reader: A code reader object informing the delegate about the scan result.
     - parameter newCaptureDevice: The capture device that was switched to
     */
    public func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {}
}
