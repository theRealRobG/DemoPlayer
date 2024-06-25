import SwiftUI

struct PlayerPage {
    struct InlinePlayerView: View {
        let assetURL: URL
        @ObservedObject private var playerEventsData = PlayerEventsData()

        var body: some View {
            PlayerViewControllerRepresentation(assetURL: assetURL, eventsData: playerEventsData)
            Spacer()
            TabView {
                MessagesView(events: playerEventsData)
                    .tabItem { Label("Logs", systemImage: "doc.plaintext") }
                VariantsView(events: playerEventsData)
                    .tabItem { Label("Variants", systemImage: "doc.on.doc") }
                TracksView(events: playerEventsData)
                    .tabItem { Label("Tracks", systemImage: "waveform.badge.magnifyingglass") }
                ErrorsView(events: playerEventsData)
                    .tabItem { Label("Errors", systemImage: "play.slash") }
            }
        }
    }

    struct FullScreenCoverPlayer: View {
        let assetURL: URL
        @ObservedObject private var playerEventsData = PlayerEventsData()

        var body: some View {
            let messagesView = MessagesView(events: playerEventsData)
            let variantsView = VariantsView(events: playerEventsData)
            let tracksView = TracksView(events: playerEventsData)
            let errorsView = ErrorsView(events: playerEventsData)
            let messagesHostingController = UIHostingController(rootView: messagesView)
            let _ = messagesHostingController.title = "Logs"
            let _ = messagesHostingController.sizingOptions = .intrinsicContentSize
            let variantsHostingController = UIHostingController(rootView: variantsView)
            let _ = variantsHostingController.title = "Variants"
            let _ = variantsHostingController.sizingOptions = .intrinsicContentSize
            let tracksHostingController = UIHostingController(rootView: tracksView)
            let _ = tracksHostingController.title = "Tracks"
            let _ = tracksHostingController.sizingOptions = .intrinsicContentSize
            let errorsHostingController = UIHostingController(rootView: errorsView)
            let _ = errorsHostingController.title = "Errors"
            let _ = errorsHostingController.sizingOptions = .intrinsicContentSize

            PlayerViewControllerRepresentation(
                assetURL: assetURL,
                eventsData: playerEventsData,
                customInfoViewControllers: [
                    messagesHostingController,
                    variantsHostingController,
                    tracksHostingController,
                    errorsHostingController
                ]
            )
        }
    }
}
