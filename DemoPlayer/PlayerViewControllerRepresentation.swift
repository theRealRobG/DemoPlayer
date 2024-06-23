import SwiftUI
import AVKit
import Combine

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
        private let playerItemEventsListener: PlayerItemEventsListener
        private var eventsCancelSet: Set<AnyCancellable>

        init(eventsData: PlayerEventsData) {
            self.eventsData = eventsData
            playerItemEventsListener = PlayerItemEventsListener()
            eventsCancelSet = Set()
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
                await setUpEventListeners(for: item)
            }
        }

        func dismantlePlayer() {
            playerItemEventsListener.cancelListeners()
            eventsCancelSet.forEach { $0.cancel() }
            eventsCancelSet.removeAll()
            player.replaceCurrentItem(with: nil)
            playerViewController.player = nil
        }

        private func setUpEventListeners(for item: AVPlayerItem) {
            playerItemEventsListener.registerListeners(for: item)
            // Each sink pushes to a `Task` to re-access `self` as there is no guarantee that the sink completion block
            // is acting on the main thread and pushing back to Task (when this class is on `MainActor`) ensures that
            // the execution occurs on main.
            playerItemEventsListener.info.$assetLoadingError.sink { [weak self] error in
                guard let error else { return }
                Task { self?.log(message: "Asset loading error: \(error)") }
            }.store(in: &eventsCancelSet)
            playerItemEventsListener.info.$assetVariants.sink { [weak self] variants in
                Task { self?.log(variants: variants) }
            }.store(in: &eventsCancelSet)
        }

        private func replaceCurrentItem(with item: AVPlayerItem) {
            player.replaceCurrentItem(with: item)
        }

        private func log(message: String) {
            eventsData.append(message: message)
        }

        private func log(variants: [PlayerItemEventsListener.AssetVariantInfo]) {
            eventsData.variants = variants
            eventsData.append(message: "Loaded variants (count: \(variants.count))")
        }
    }
}
