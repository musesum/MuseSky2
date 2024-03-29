import SwiftUI
import RealityKit
import MuFlo // NextFrame
import MuVision
import MuHand

#if os(visionOS)

struct ContentView: View {

    @State private var showImmersiveSpace = false
    @State public var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var handsTracker: HandsTracker

    func immersion(show: Bool) {

        let menuSkyView = MenuSkyView.shared
        let metalLayer = menuSkyView.skyCanvas.pipeline.metalLayer

        immersiveSpaceIsShown = show
        NextFrame.shared.pause = show
        metalLayer.opacity = show ? 0 : 1
        RenderDepth.state = show ? .immer : .metal
    }

    var body: some View {

        ZStack(alignment: .bottom) {
            if !immersiveSpaceIsShown {
                MenuSkyView.shared
                    .frame(minWidth: 640, minHeight: 480)
                    .frame(maxWidth: 640, maxHeight: 480)
            } else {
                
                MenuSkyView.shared
                    .frame(minWidth: 320, minHeight: 400)
                    .frame(maxWidth: 320, maxHeight: 400)
            }

            Toggle(showImmersiveSpace
                   ? "Passthrough"
                   : "Immersive",
                   isOn: $showImmersiveSpace)
            .toggleStyle(.button)
            .padding(EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6))
            .glassBackgroundEffect()

            .onChange(of: showImmersiveSpace) { _, newValue in
                Task {
                    if newValue {
                        switch await openImmersiveSpace(id: "ImmersiveSpace") {
                        case .opened: immersion(show: true)
                        default     : immersion(show: false)

                        }
                    } else if immersiveSpaceIsShown {
                        await dismissImmersiveSpace()
                        immersion(show: false)
                    }
                }
            }
            .task {
                await handsTracker.startHands()
            }
            .task {
                await handsTracker.updateHands()
            }
            .task {
                await handsTracker.monitorSessionEvents()
            }
        }

    }
}
#endif
