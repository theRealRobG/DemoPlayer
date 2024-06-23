import SwiftUI

let demoAssetURL = URL(
    string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8"
)!

struct ContentView: View {
    var body: some View {
        NavigationStack {
            NavigationLink {
                PlayerPageView(assetURL: demoAssetURL)
            } label: {
                Label("Play", systemImage: "play")
            }
        }
    }
}

#Preview {
    ContentView()
}
