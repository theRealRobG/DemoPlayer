import AVFoundation
import SwiftUI

// Constants
//let defaultUrl = "https://devstreaming-cdn.apple.com/videos/streaming/examples/adv_dv_atmos/main.m3u8"
let defaultUrl = "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8"
let playerUsesCustomInfoViewControllers: Bool = {
    #if os(iOS)
    false
    #else
    true
    #endif
}()

@main
struct DemoPlayerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    let avAudioSession = AVAudioSession.sharedInstance()
                    try? avAudioSession.setCategory(.playback)
                    try? avAudioSession.setMode(.moviePlayback)
                }
        }
    }
}
