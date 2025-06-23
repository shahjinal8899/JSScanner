
import UIKit

/// Overlay over the camera view to display the area (a square) where to scan the code.
public final class ReaderOverlayView: UIView {
    private var overlay: CAShapeLayer = {
        var overlay             = CAShapeLayer()
        overlay.backgroundColor = UIColor.clear.cgColor
        overlay.fillColor       = UIColor.clear.cgColor
        overlay.strokeColor     = UIColor.clear.cgColor //white
        overlay.lineWidth       = 3
        overlay.lineDashPattern = [7.0, 7.0]
        overlay.lineDashPhase   = 0
        
        return overlay
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupOverlay()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupOverlay()
    }
    
    private func setupOverlay() {
        layer.addSublayer(overlay)
    }
    
    var overlayColor: UIColor = UIColor.white {
        didSet {
            self.overlay.strokeColor = overlayColor.cgColor
            
            self.setNeedsDisplay()
        }
    }
    
    public override func draw(_ rect: CGRect) {
        //    var innerRect = rect.insetBy(dx: 50, dy: 50)
        //CHANGE ON 28 Dec 2018 - (Camera dotted line for scanning)
        var innerRect = rect.insetBy(dx: 20, dy: 20)
        let minSize   = min(innerRect.width, innerRect.height)
        
        if innerRect.width != minSize {
            innerRect.origin.x   += (innerRect.width - minSize) / 2
            innerRect.size.width = minSize
        }
        else if innerRect.height != minSize {
            innerRect.origin.y    += (innerRect.height - minSize) / 2
            innerRect.size.height = minSize
        }
        
        overlay.path = UIBezierPath(roundedRect: innerRect, cornerRadius: 5).cgPath
    }
}
