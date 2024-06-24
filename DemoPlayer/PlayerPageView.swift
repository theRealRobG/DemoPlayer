import SwiftUI

struct PlayerPageView: View {
    let assetURL: URL

    @StateObject private var playerEventsData = PlayerEventsData()
    
    var body: some View {
        PlayerViewControllerRepresentation(assetURL: assetURL, eventsData: playerEventsData)
        Spacer()
        TabView {
            MessagesView(messages: playerEventsData.messages)
                .tabItem { Label("Logs", systemImage: "doc.plaintext") }
            VariantsView(variants: playerEventsData.variants)
                .tabItem { Label("Variants", systemImage: "doc.on.doc") }
            TracksView(tracks: playerEventsData.tracks)
                .tabItem { Label("Tracks", systemImage: "waveform.badge.magnifyingglass") }
            ErrorsView(errors: playerEventsData.errors)
                .tabItem { Label("Errors", systemImage: "play.slash") }
        }
    }
}
