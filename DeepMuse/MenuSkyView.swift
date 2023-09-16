//
//  MenuSkyView.swift
//  DeepMuse
//
//  Created by warren on 9/14/23.
//  Copyright © 2023 DeepMuse. All rights reserved.
//

import SwiftUI
import BackgroundTasks
import MuFlo
import MuAudio
import MuMenu
import MuSkyFlo

struct MenuSkyView: View {

    public static let shared = MenuSkyView()
    var menuView: MenuView!
    var hostView: UIView!
    var midi: MuMidi?
    var pipeline: SkyPipeline!
    var touchView: SkyTouchView!
    var settingUp = true
    var hostingController: HostingController!

    let archive = FloArchive(bundle: MuSkyFlo.bundle,
                             archive: "Snapshot",
                             scripts:  ["sky", "shader", "model", "menu", "plato", "cube", "midi", "corner"],
                             textures: ["draw"])

    public init() {
        midi = MuMidi(root: archive.root˚)
        if let midi {
            TouchMidi.touchRemote = midi
        }
        _ = MuAudio.shared // MuAudio.shared.test()
#if os(xrOS)
        let bounds = CGRect(x: 0, y: 0, width: 1920, height: 1080)
#else
        let bounds = UIScreen.main.bounds
#endif
        pipeline = SkyPipeline(bounds, archive.root˚)
        TouchCanvas.shared.touchFlo.parseRoot(archive.root˚, archive)
        touchView = SkyTouchView(bounds)
        touchView.layer.addSublayer(pipeline!.metalLayer)

        menuView = MenuView(archive.root˚, touchView, self)
        hostView = UIHostingController(rootView: menuView).view
        hostingController = HostingController(rootView: self)
        NextFrame.shared.addFrameDelegate("Sky".hash, self)
    }

    var body: some View {
        VStack {
            menuView

        }
    }
}
extension MenuSkyView: MenuDelegate {

    func window(bounds: CGRect, insets: EdgeInsets) {

        let width = bounds.width + insets.leading + insets.trailing
        let height = bounds.height + insets.top + insets.bottom
#if os(xrOS)
        let scale = CGFloat(3) //??? scale
#else
        let scale = UIScreen.main.scale
#endif
        let viewSize = CGSize(width: width * scale, height: height * scale)
        TouchCanvas.shared.touchFlo.viewSize = viewSize
        touchView?.frame = CGRect(x: 0, y: 0, width: width, height: height)
        pipeline?.resize(viewSize, scale)
    }
}
extension MenuSkyView: NextFrameDelegate {

    func nextFrame() -> Bool {
        pipeline?.draw()
        return true
    }
    func cancel(_ key: Int) {
        NextFrame.shared.removeDelegate(key)
    }

}

