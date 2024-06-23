import SwiftUI

let defaultUrl = "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8"

struct ContentView: View {
    @State var assetUrl = ""
    private var playbackUrl: String { assetUrl.isEmpty ? defaultUrl : assetUrl }

    var body: some View {
        NavigationStack {
            TextField(text: $assetUrl) {
                Text("Asset URL")
            }
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .textContentType(.URL)
            .textFieldStyle(.roundedBorder)
            .padding([.top, .horizontal])

            Text("If no URL is provided then a default asset is used.")
                .font(.footnote)
                .fontWeight(.light)
                .padding(.bottom)

            NavigationLink {
                if let url = URL(string: playbackUrl) {
                    PlayerPageView(assetURL: url)
                } else {
                    Text("Invalid URL: \(assetUrl)")
                }
            } label: {
                Label("Play", systemImage: "play")
            }
        }
    }
}

#Preview {
    ContentView()
}
