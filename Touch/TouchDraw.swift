
import QuartzCore
import UIKit
import Tr3

class TouchDraw {

    private let brushTilt˚  : Tr3
    private let brushPress˚ : Tr3
    private let brushSize˚  : Tr3
    private let linePrev˚   : Tr3 // beginning of line
    private let lineNext˚   : Tr3 // end of line
    private let inForce˚    : Tr3 // pressure
    private let inRadius˚   : Tr3 // finger radius
    private let inAzimuth˚  : Tr3 // apple pencil angle
    private let screenFill˚ : Tr3
    private let drawDot˚    : Tr3

    private var brushTilt = false          // via brushTilt˚
    private var brushPress = true          // via brushPress˚
    private var brushSize = CGFloat(1)     // via brushSize˚
    private var linePrev = CGPoint.zero    // via linePrev˚
    private var lineNext = CGPoint.zero    // via lineNext˚
    private var inForce = CGFloat(0)       // via inForce˚
    private var inRadius = CGFloat(0)      // via inRadius˚
    private var inAzimuth = CGPoint.zero   // var inAzimuth˚
    private var fillValue = Float(-1)

    init(_ root: Tr3) {

        let sky     = root.bindPath("sky")
        let input   = sky.bindPath("input")
        let draw    = sky.bindPath("draw")
        let brush   = draw.bindPath("brush")
        let line    = draw.bindPath("line")
        let screen  = draw.bindPath("screen")

        brushTilt˚  = input .bindPath("tilt"   )
        brushPress˚ = brush .bindPath("press"  )
        brushSize˚  = brush .bindPath("size"   )
        linePrev˚   = line  .bindPath("prev"   )
        lineNext˚   = line  .bindPath("next"   )
        inForce˚    = input .bindPath("force"  )
        inRadius˚   = input .bindPath("radius" )
        inAzimuth˚  = input .bindPath("azimuth")
        screenFill˚ = screen.bindPath("fill"   )
        drawDot˚    = draw  .bindPath("dot"    )

        setupClosures()
    }
    func setupClosures() {
        brushTilt˚ .addClosure { t, _ in self.brushTilt  = t.BoolVal() }
        brushPress˚.addClosure { t, _ in self.brushPress = t.BoolVal() }
        brushSize˚ .addClosure { t, _ in self.brushSize  = t.CGFloatVal() ?? 1 }
        linePrev˚  .addClosure { t, _ in self.linePrev   = t.CGPointVal() ?? .zero }
        lineNext˚  .addClosure { t, _ in self.lineNext   = t.CGPointVal() ?? .zero }
        inForce˚   .addClosure { t, _ in self.inForce    = t.CGFloatVal() ?? 1 }
        inRadius˚  .addClosure { t, _ in self.inRadius   = t.CGFloatVal() ?? 1 }
        inAzimuth˚ .addClosure { t, _ in self.inAzimuth  = t.CGPointVal() ?? .zero }
        screenFill˚.addClosure { t, _ in self.fillValue  = t.FloatVal() ?? -1 }

        drawDot˚   .addClosure { t, _ in

            if let exprs = t.val as? Tr3Exprs,
               let x = exprs.nameAny["x"] as? Tr3ValScalar,
               let y = exprs.nameAny["y"] as? Tr3ValScalar,
               let z = exprs.nameAny["z"] as? Tr3ValScalar {
                let time = Date().timeIntervalSince1970
                let margin = CGFloat(48)
                let xs = CGFloat(2388/2)
                let ys = CGFloat(1668/2)
                let xx = CGFloat(x.now) / 12
                let yy = 1 - CGFloat(y.now / 12)
                let xxx = CGFloat(xx * xs) + margin
                let yyy = CGFloat(yy * ys) - margin
                let point = CGPoint(x: xxx, y: yyy)
                let radius = CGFloat(z.now/2 + 1)

                let pointStr = String(format: "(%.2f,%.2f)", point.x, point.y)
                //print("dot x:\(x.now) y:\(y.now) xs:\(xs) ys:\(ys) \(pointStr):\(radius)")

                let item0 = TouchCanvasItem(time, point, point, radius, radius, .zero, .began)
                TouchView.shared.addMidiCanvasItem(item0)
//                let item1 = TouchCanvasItem(time, point, point, radius, radius, .zero, .ended)
//                TouchView.shared.addMidiCanvasItem(item1)
            }
        }
    }

    public func update(_ item: TouchCanvasItem) -> CGFloat {

        // if using Apple Pencil and brush tilt is turned on
        if item.force > 0, brushTilt {
            let azi = CGPoint(x: -item.azimuth.dy, y: -item.azimuth.dx)
            inAzimuth˚.setAny(azi, [.activate]) // will update local azimuth via Tr3Graph
            //PrintGesture("azimuth dXY(%.2f,%.2f)", item.azimuth.dx, item.azimuth.dy)
        }
        
        // if brush press is turned on
        var radiusNow = CGFloat(1)
        if brushPress  {
            if inForce > 0 || item.azimuth.dx != 0.0 {
                inForce˚.setAny(item.force, [.activate]) // will update local azimuth via Tr3Graph
                radiusNow = brushSize
            } else {
                inRadius˚.setAny(item.radius, [.activate])
                radiusNow = inRadius
            }
        }
        else {
            radiusNow = brushSize
        }
        return radiusNow
    }

    /**
     Either fill or draw inside texture
     - returns: true if filled, false if drawn
     */
     func drawTexture(_ texBuf: UnsafeMutablePointer<UInt32>,
                     size: CGSize) -> Bool {

        if TextureData.shared.data != nil {
            fillValue = -1 // preempt fill after data
            drawData()
            return false //? true // did fill, so copy to 2nd texture
        }
        else if fillValue > 255 {
            let fill = UInt32(fillValue)
            drawFill(fill)
            fillValue = -1
            return false //? true // did fill, so copy to 2nd texture
        }
        else if fillValue >= 0 {
            let v8 = UInt32(fillValue * 255)
            let fill = (v8 << 24) + (v8 << 16) + (v8 << 8) + v8
            drawFill(fill)
            fillValue = -1
            return false //? true // did fill, so copy to 2nd texture
        }
        else {

            func updateRadius(_ radius: CGFloat) -> CGFloat {
                if brushPress {
                    inRadius˚.setAny(radius, [])
                    brushSize˚.setAny(radius, [.activate]) // will update brushSize via closure
                    return brushSize
                }
                return radius
            }

            TouchView.shared.flushTouchCanvas { (point,radius) in
                let radius = updateRadius(radius)
                drawPoint(point, radius, 127, texBuf, size)
            }
            return false // didn't fill so don't duplicate 2nd texture
        }

        func drawPoint(_ point: CGPoint,
                       _ radius: CGFloat,
                       _ colori: UInt32, // index to color palette
                       _ texBuf: UnsafeMutablePointer<UInt32>,
                       _ drawSize: CGSize) {

            if point == .zero { return }
            let p = point * UIScreen.main.scale
            let viewSize = SkyPipeline.shared.viewSize
            let p1 = MuAspect.viewPointToTexture(p, viewSize: viewSize, texSize: drawSize)

            let r = radius * 2.0 - 1
            let r2 = Int(r * r / 4.0)
            let xs = Int(drawSize.width)
            let ys = Int(drawSize.height)
            let px = Int(p1.x)
            let py = Int(p1.y)

            var x0 = Int(p1.x - radius - 0.5)
            var y0 = Int(p1.y - radius - 0.5)
            var x1 = Int(p1.x + radius + 0.5)
            var y1 = Int(p1.y + radius + 0.5)

            if x0 < 0 { x0 += xs }
            if y0 < 0 { y0 += ys }
            while x1 < x0 { x1 += xs }
            while y1 < y0 { y1 += ys }

            if radius == 1 {
                texBuf[y0 * xs + x0] = colori
                return
            }

            for y in y0 ..< y1 {

                for x in x0 ..< x1  {

                    let xd = (x - px) * (x - px)
                    let yd = (y - py) * (y - py)

                    if xd + yd < r2 {

                        let yy = (y+ys)%ys      // wrapped pixel y index
                        let xx = (x+xs)%xs      // wrapped pixel x index
                        let ii = yy * xs + xx   // final pixel x, y index into buffer

                        texBuf[ii] = colori     // set the buffer to value
                    }
                }
            }
        }
        func drawFill(_ fill: UInt32) {

            let w = Int(size.width)
            let h = Int(size.height)
            let count = w * h // count

            for i in 0 ..< count {
                texBuf[i] = fill
            }
        }
        func drawData() {

            let w = Int(size.width)
            let h = Int(size.height)
            let count = w * h // count

            TextureData.shared.data?.withUnsafeBytes { dataPtr in
                let tex32Ptr = dataPtr.bindMemory(to: UInt32.self)
                for i in 0 ..< count {
                    texBuf[i] = tex32Ptr[i]
                }
            }
            TextureData.shared.data = nil
        }
    }
}
