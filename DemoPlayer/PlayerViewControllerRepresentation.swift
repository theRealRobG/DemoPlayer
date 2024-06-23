import SwiftUI
import AVKit

@MainActor
struct PlayerViewControllerRepresentation: UIViewControllerRepresentable {
    let assetURL: URL
    let eventsData: PlayerEventsData

    func makeCoordinator() -> Coordinator {
        Coordinator(eventsData: eventsData)
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        context.coordinator.loadAsset(url: assetURL)
        return context.coordinator.playerViewController
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // no-op
    }
}

extension PlayerViewControllerRepresentation {
    @MainActor
    class Coordinator {
        let playerViewController: AVPlayerViewController
        
        private let player: AVPlayer
        private let eventsData: PlayerEventsData

        init(eventsData: PlayerEventsData) {
            self.eventsData = eventsData
            playerViewController = AVPlayerViewController()
            player = AVPlayer()
            playerViewController.player = player
            player.play()
        }

        func loadAsset(url: URL) {
            // Using a detached task to ensure we do not hold up the main thread.
            Task.detached { [weak self] in
                guard let self else { return }
                let asset = AVURLAsset(url: url)
                let item = AVPlayerItem(asset: asset)
                // The Task is detached so using actor isolated methods to ensure we are running on main.
                await self.replaceCurrentItem(with: item)
                do {
                    let tracks = try await asset.load(.tracks)
                    await log(tracks: tracks)
                } catch {
                    await log(message: "Could not load tracks: \(error)")
                }
            }
        }

        private func replaceCurrentItem(with item: AVPlayerItem) {
            player.replaceCurrentItem(with: item)
        }

        private func log(message: String) {
            eventsData.append(message: message)
        }

        private func log(tracks: [AVAssetTrack]) {
            eventsData.append(message: "Loaded tracks (count: \(tracks.count))")
            for track in tracks {
                eventsData.append(message: "Loaded track: \(track)")
            }
        }
    }
}
