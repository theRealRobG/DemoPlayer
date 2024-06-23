import AVFoundation
import SwiftUI

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
