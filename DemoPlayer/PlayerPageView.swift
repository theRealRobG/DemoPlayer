import SwiftUI

struct PlayerPageView: View {
    let assetURL: URL

    @StateObject private var playerEventsData = PlayerEventsData()
    
    var body: some View {
        PlayerViewControllerRepresentation(assetURL: assetURL, eventsData: playerEventsData)
        Spacer()
        TabView {
            List(playerEventsData.messages) {
                Text($0.message)
            }
            .tabItem { Label("Logs", systemImage: "doc.plaintext") }
            VariantsView(variants: playerEventsData.variants)
                .tabItem { Label("Variants", systemImage: "doc.on.doc") }
        }
    }
}

#Preview {
    PlayerPageView(assetURL: demoAssetURL)
}
