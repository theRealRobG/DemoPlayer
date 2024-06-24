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
                Task { self?.log(assetLoadingError: error) }
            }.store(in: &eventsCancelSet)
            playerItemEventsListener.info.$fatalPlayerItemError.sink { [weak self] error in
                guard let error else { return }
                Task { self?.log(playerItemFatalError: error) }
            }.store(in: &eventsCancelSet)
            playerItemEventsListener.info.$errorLogs
                // In some scenarios the error log is appended to very frequently (e.g. if the internet connection is
                // lost and the user seeks, can be replicated by switching to "airplane mode" during playback). When
                // this happens, if we continue to update the UI for each update, it can completely lock up for quite
                // some time. Therefore, to avoid this, we debounce updates to the error log so that only the last value
                // is published after a short period of time.
                .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
                .sink { [weak self] logs in
                    guard !logs.isEmpty else { return }
                    self?.log(errorLogs: logs)
                }
                .store(in: &eventsCancelSet)
            playerItemEventsListener.info.$assetVariants.sink { [weak self] variants in
                guard !variants.isEmpty else { return }
                Task { self?.log(variants: variants) }
            }.store(in: &eventsCancelSet)
            playerItemEventsListener.info.$audioTrackInfo.sink { [weak self] track in
                Task { self?.log(audioTrackInfo: track) }
            }.store(in: &eventsCancelSet)
            playerItemEventsListener.info.$videoTrackInfo.sink { [weak self] track in
                Task { self?.log(videoTrackInfo: track) }
            }.store(in: &eventsCancelSet)
            playerItemEventsListener.info.$captionTrackInfo.sink { [weak self] track in
                Task { self?.log(captionTrackInfo: track) }
            }.store(in: &eventsCancelSet)
            playerItemEventsListener.info.$subtitleTrackInfo.sink { [weak self] track in
                Task { self?.log(subtitleTrackInfo: track) }
            }.store(in: &eventsCancelSet)
        }

        private func replaceCurrentItem(with item: AVPlayerItem) {
            player.replaceCurrentItem(with: item)
        }

        private func log(message: String) {
            eventsData.append(message: message)
        }

        private func log(assetLoadingError error: Error) {
            eventsData.errors.assetLoadingError = error
            log(message: "Asset loading failed")
        }

        private func log(playerItemFatalError error: Error) {
            eventsData.errors.playerItemFatalError = error
            log(message: "Player item failed")
        }

        private func log(errorLogs logs: [AVPlayerItemErrorLogEvent]) {
            eventsData.errors.playerItemErrorLogs = logs
            log(message: "Error log changed")
        }

        private func log(variants: [PlayerItemEventsListener.AssetVariantInfo]) {
            eventsData.variants = variants
            eventsData.append(message: "Variants changed (count: \(variants.count))")
        }

        private func log(audioTrackInfo: CMFormatDescription?) {
            eventsData.tracks.set(audioTrackInfo: audioTrackInfo)
            log(message: "Audio track changed")
        }
        private func log(videoTrackInfo: CMFormatDescription?) {
            eventsData.tracks.set(videoTrackInfo: videoTrackInfo)
            log(message: "Video track changed")
        }
        private func log(captionTrackInfo: CMFormatDescription?) {
            eventsData.tracks.set(captionTrackInfo: captionTrackInfo)
            log(message: "Caption track changed")
        }
        private func log(subtitleTrackInfo: CMFormatDescription?) {
            eventsData.tracks.set(subtitleTrackInfo: subtitleTrackInfo)
            log(message: "Subtitle track changed")
        }
    }
}
