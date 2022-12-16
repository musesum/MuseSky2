//  Created by warren on 12/15/22.


import SwiftUI

extension TouchView { // +Menu

    /// if touching menu, then assign finger
    func assignFingerMenu(_ key: Int,
                          _ touch: UITouch) -> Bool {

        let nextXY = touch.preciseLocation(in: nil)

        for touchVm in touchVms {
            if let (corner, nodeVm) = touchVm.hitTest(nextXY) {

                let touchMenu = TouchMenu(touchVm, isRemote: false)
                let hashPath = nodeVm.node.hashPath
                touchMenu.addTouchMenuItem(key,corner, hashPath, touch)
                menuKey[key] = touchMenu

                
                timerKey[key] = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                    let isDone = touchMenu.buffer.flush()
                    if isDone {
                        timer.invalidate()
                        self.timerKey.removeValue(forKey: key)
                        self.menuKey.removeValue(forKey: key)
                    }
                }
                return true
            }
        }
        return false
    }


}
