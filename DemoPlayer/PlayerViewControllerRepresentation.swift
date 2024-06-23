import SwiftUI
import AVKit

@MainActor
struct PlayerViewControllerRepresentation: UIViewControllerRepresentable {
    let assetURL: URL
    let eventsData: PlayerEventsData

    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: Coordinator) {
        coordinator.dismantlePlayer()
    }

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
                    let (tracks, variants) = try await asset.load(.tracks, .variants)
                    await log(tracks: tracks)
                    await log(variants: variants)
                } catch {
                    await log(message: "Could not load asset: \(error)")
                }
            }
        }

        func dismantlePlayer() {
            player.replaceCurrentItem(with: nil)
            playerViewController.player = nil
        }

        private func replaceCurrentItem(with item: AVPlayerItem) {
            player.replaceCurrentItem(with: item)
        }

        private func log(message: String) {
            eventsData.append(message: message)
        }

        private func log(tracks: [AVAssetTrack]) {
            eventsData.tracks = tracks
            eventsData.append(message: "Loaded tracks (count: \(tracks.count))")
        }

        private func log(variants: [AVAssetVariant]) {
            eventsData.variants = variants
            eventsData.append(message: "Loaded variants (count: \(variants.count))")
        }
    }
}
