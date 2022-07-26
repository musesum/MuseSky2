
import SwiftUI
import MuMenu
import Tr3
import MultipeerConnectivity


class TouchView: UIView, UIGestureRecognizerDelegate {
    static let shared = TouchView()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(frame:.zero)
        let bounds = UIScreen.main.bounds
        let w = bounds.size.width
        let h = bounds.size.height
        frame = CGRect(x: 0, y: 0, width: w, height: h)
        isMultipleTouchEnabled = true
        PeersController.shared.peersDelegates.append(self)
    }
    deinit {
        PeersController.shared.remove(peersDelegate: self)
    }


    /// When starting new touch, assign finger to either Menu or Canvas.
    func beginTouches(_ touches: Set<UITouch>) {

        for touch in touches {
            if      TouchMenu.beginTouch(touch) { }
            else if TouchCanvas.beginTouch(touch) { }
        }
    }

    /// Continue dispatching finger to canvas or menu
    func updateTouches(_ touches: Set<UITouch>) {

        for touch in touches {
            if      TouchCanvas.updateTouch(touch) { }
            else if TouchMenu.updateTouch(touch) { }
            else { print("*** unknown touch \(touch.hash)") }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { beginTouches(touches) }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) { updateTouches(touches) }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { updateTouches(touches) }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { updateTouches(touches) }
}
