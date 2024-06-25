import SwiftUI

struct ContentView: View {
    @State var assetUrl = ""
    @State var playerPresented = false
    private var playbackUrl: String { assetUrl.isEmpty ? defaultUrl : assetUrl }

    var body: some View {
        NavigationStack {
            TextField(text: $assetUrl) {
                Text("Asset URL")
            }
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .textContentType(.URL)
            .textFieldStyle(textFieldStyle())
            .padding([.top, .horizontal])

            Text("If no URL is provided then a default asset is used.")
                .font(.footnote)
                .fontWeight(.light)
                .padding(.bottom)

            if playerUsesCustomInfoViewControllers {
                Button {
                    playerPresented = true
                } label: {
                    Label("Play", systemImage: "play")
                }
            } else {
                NavigationLink {
                    if let url = URL(string: playbackUrl) {
                        PlayerPage.InlinePlayerView(assetURL: url)
                    } else {
                        Text("Invalid URL: \(assetUrl)")
                    }
                } label: {
                    Label("Play", systemImage: "play")
                }
            }
        }
        .fullScreenCover(isPresented: $playerPresented) {
            if let url = URL(string: playbackUrl) {
                PlayerPage.FullScreenCoverPlayer(assetURL: url)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("Invalid URL: \(assetUrl)")
            }
        }
    }

    private func textFieldStyle() -> some TextFieldStyle {
        #if os(tvOS)
        return PlainTextFieldStyle()
        #else
        return RoundedBorderTextFieldStyle()
        #endif
    }
}

#Preview {
    ContentView()
}
