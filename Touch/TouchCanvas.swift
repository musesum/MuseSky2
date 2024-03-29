//  Created by warren on 2/5/19.

import UIKit
import MuMenu // PeersController
import MuFlo // digits
import MuPar // visit
import MuTime // DoubleBuffer

class TouchCanvas {

    private var touchRepeat˚: Flo?
    var touchRepeat = true /// repeat touch, even when not moving finger

    let buffer = DoubleBuffer<TouchCanvasItem>(internalLoop: false)
    
    internal var lastItem: TouchCanvasItem? // repeat last touch until isDone
    internal var quadXYR = QuadXYR()
    internal var indexNow = 0
    internal var isDone = false
    internal var filterForce = CGFloat(0) // Apple Pencil begins at 0.333; filter the blotch

    static var canvasKey = [Int: TouchCanvas]()
    private var isRemote: Bool
    
    init(isRemote: Bool) {
        self.isRemote = isRemote
        buffer.flusher = self

        touchRepeat˚ = SkyFlo.shared.root.bindPath("shader.pipe.draw.on") { flo, _ in
            if let p = flo.cgPoint {
                self.touchRepeat = (abs(p.x - 0.5) > 0.001 ||
                                    abs(p.y - 0.5) > 0.001)
            }
        }
    }
    func addTouchItem(_ key: Int,
                      _ touch: UITouch) {
        
        let force = touch.force
        let radius = touch.majorRadius
        let nextXY = touch.preciseLocation(in: nil)
        let phase = touch.phase
        let azimuth = touch.azimuthAngle(in: nil)
        let altitude = touch.altitudeAngle
        
        let item = makeTouchItem(key, force, radius, nextXY, phase, azimuth, altitude, Visitor(.canvas))
        if PeersController.shared.hasPeers {
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(item)
                PeersController.shared.sendMessage(data, viaStream: true)
            } catch {
                print(error)
            }
        }
    }
    
    func makeTouchItem(_ key     : Int,
                       _ force   : CGFloat,
                       _ radius  : CGFloat,
                       _ nextXY  : CGPoint,
                       _ phase   : UITouch.Phase,
                       _ azimuth : CGFloat,
                       _ altitude: CGFloat,
                       _ visit   : Visitor) -> TouchCanvasItem {
        
        let alti = (.pi/2 - altitude) / .pi/2
        let azim = CGVector(dx: -sin(azimuth) * alti, dy: cos(azimuth) * alti)
        var force = Float(force)
        var radius = Float(radius)
        
        if let lastItem {
            
            let forceFilter = Float(0.90)
            force = (lastItem.force * forceFilter) + (force * (1-forceFilter))
            
            let radiusFilter = Float(0.95)
            radius = (lastItem.radius * radiusFilter) + (radius * (1-radiusFilter))
            //print(String(format: "* %.3f -> %.3f", lastItem.force, force))
        } else {
            force = 0 // bug: always begins at 0.5
        }
        let item = TouchCanvasItem(key, nextXY, radius, force, azim, phase, visit)
        buffer.append(item)
        return item
    }
}

extension TouchCanvas: BufferFlushDelegate {

    typealias Item = TouchCanvasItem

    func flushItem<Item>(_ item: Item) -> Bool {
        let item = item as! TouchCanvasItem
        lastItem = item

        let radius = TouchDraw.shared.update(item, item.visit())
        let p = CGPoint(x: CGFloat(item.nextX), y: CGFloat(item.nextY))
        isDone = item.isDone()
        quadXYR.addXYR(p, radius, isDone)
        quadXYR.iterate12()
        return isDone
    }

    func flushTouches()  {

        if buffer.isEmpty,
            touchRepeat,
            let lastItem {
            // finger is stationary repeat last movement
            _ = flushItem(lastItem)
        } else {
            isDone = buffer.flushBuf()
        }
    }
}

extension TouchCanvas {

    static func beginTouch(_ touch: UITouch) -> Bool {
        let touchCanvas = TouchCanvas(isRemote: false)
        let key = touch.hash
        canvasKey[key] = touchCanvas
        touchCanvas.addTouchItem(key, touch)
        return true
    }
    static func updateTouch(_ touch: UITouch) -> Bool {
        let key = touch.hash
        if let touchCanvas = canvasKey[key] {
            touchCanvas.addTouchItem(key, touch)
            return true
        }
        return false
    }
    static func remoteItem(_ item: TouchCanvasItem) {
        if let canvas = canvasKey[item.key] {
            canvas.buffer.append(item)
        } else {
            let canvas = TouchCanvas(isRemote: true)
            canvasKey[item.key] = canvas
            canvas.buffer.append(item)
        }
    }
    static func addCanvasItem(_ item: TouchCanvasItem,
                              isRemote: Bool) {
        let key = item.key
        if canvasKey[key] == nil {
            canvasKey[key] = TouchCanvas(isRemote: isRemote)
        }
        canvasKey[key]?.buffer.append(item)
    }
    static func drawPoint(_ point: CGPoint, _ radius: CGFloat) {
        for (key, canvas) in canvasKey {
            canvas.flushTouches()
            if canvas.isDone {
                canvasKey.removeValue(forKey: key)
            }
        }
    }
    static func flushTouchCanvas() {

        for (key, canvas) in canvasKey {
            canvas.flushTouches()
            if canvas.isDone {
                canvasKey.removeValue(forKey: key)
            }
        }
    }

}
