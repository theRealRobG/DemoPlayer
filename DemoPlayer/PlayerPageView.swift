import SwiftUI

struct PlayerPageView: View {
    let assetURL: URL

    @StateObject private var playerEventsData = PlayerEventsData()
    
    var body: some View {
        PlayerViewControllerRepresentation(assetURL: assetURL, eventsData: playerEventsData)
        Spacer()
        List {
            ForEach(playerEventsData.messages) {
                Text($0.message)
            }
        }
    }
}

#Preview {
    PlayerPageView(assetURL: demoAssetURL)
}
