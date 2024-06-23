import AVFoundation
import Combine

class PlayerItemEventsListener {
    let info = EventInfo()
    private var cancelSet = Set<AnyCancellable>()

    func registerListeners(for item: AVPlayerItem) {
        Task.detached { [weak self, weak item] in
            guard let self else { return }
            self.registerErrorLogListener(for: item)
            self.registerFailedToPlayToEndTimeListener(for: item)
            await self.registerVariantsListener(for: item)
        }
    }

    func cancelListeners() {
        cancelSet.forEach { $0.cancel() }
        cancelSet.removeAll()
    }

    // MARK: - Error logs

    private func registerErrorLogListener(for item: AVPlayerItem?) {
        if let events = item?.errorLog()?.events {
            notifyErrorLogsDidChange(logs: events)
        }
        NotificationCenter.default.publisher(for: AVPlayerItem.newErrorLogEntryNotification)
            .compactMap { [weak item] in
                PlayerItemNotification(notification: $0, originalItem: item)?.item.errorLog()?.events
            }
            .sink { [weak self] in self?.notifyErrorLogsDidChange(logs: $0) }
            .store(in: &cancelSet)
    }

    private func notifyErrorLogsDidChange(logs: [AVPlayerItemErrorLogEvent]) {
        info.errorLogs = logs
    }

    // MARK: - Failed to play to end time

    private func registerFailedToPlayToEndTimeListener(for item: AVPlayerItem?) {
        if let error = item?.error {
            notifyFailedToPlayToEndTime(error: error)
        }
        NotificationCenter.default.publisher(for: AVPlayerItem.failedToPlayToEndTimeNotification)
            .compactMap { [weak item] in
                PlayerItemNotification(notification: $0, originalItem: item)?
                    .userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error
            }
            .sink { [weak self] in self?.notifyFailedToPlayToEndTime(error: $0) }
            .store(in: &cancelSet)
    }

    private func notifyFailedToPlayToEndTime(error: Error) {
        info.fatalPlayerItemError = error
    }

    // MARK: - Media selection did change

    private func registerVariantsListener(for item: AVPlayerItem?) async {
        guard let asset = item?.asset as? AVURLAsset else { return }
        let variants: [AVAssetVariant]
        let audioGroup: AVMediaSelectionGroup
        do {
            variants = try await asset.load(.variants)
            guard let someAudioGroup = try await asset.loadMediaSelectionGroup(for: .audible) else {
                throw NoAudioGroupLoadingError()
            }
            audioGroup = someAudioGroup
        } catch {
            info.assetLoadingError = error
            return
        }
        guard let item else { return }
        notifyVariantsChanged(item: item, audioGroup: audioGroup, variants: variants)
        NotificationCenter.default.publisher(for: AVPlayerItem.mediaSelectionDidChangeNotification)
            .compactMap { [weak item] in PlayerItemNotification(notification: $0, originalItem: item) }
            .sink { [weak self, audioGroup, variants] in
                self?.notifyVariantsChanged(item: $0.item, audioGroup: audioGroup, variants: variants)
            }
            .store(in: &cancelSet)
    }

    private func notifyVariantsChanged(
        item: AVPlayerItem,
        audioGroup: AVMediaSelectionGroup,
        variants: [AVAssetVariant]
    ) {
        guard let selectedAudio = item.currentMediaSelection.selectedMediaOption(in: audioGroup) else {
            info.assetVariants = variants.map {
                AssetVariantInfo(variant: $0, audioRenditionInfoForCurrentMediaSelection: nil)
            }
            return
        }
        info.assetVariants = variants.map {
            let audioRenditionInfo = $0.audioAttributes?.renditionSpecificAttributes(for: selectedAudio)
            return AssetVariantInfo(
                variant: $0,
                audioRenditionInfoForCurrentMediaSelection: audioRenditionInfo
            )
        }
    }
}

extension PlayerItemEventsListener {
    class EventInfo {
        @Published var assetLoadingError: Error?
        @Published var fatalPlayerItemError: Error?
        @Published var errorLogs = [AVPlayerItemErrorLogEvent]()
        @Published var assetVariants = [AssetVariantInfo]()
    }

    struct AssetVariantInfo: Identifiable {
        let variant: AVAssetVariant
        let audioRenditionInfoForCurrentMediaSelection: AVAssetVariant.AudioAttributes.RenditionSpecificAttributes?

        var id: ObjectIdentifier { ObjectIdentifier(variant) }
    }

    struct NoAudioGroupLoadingError: Error, CustomNSError, CustomStringConvertible {
        static let errorDomain = "AssetVariantLoadingErrorDomain"
        let errorCode = 1
        let errorUserInfo = [NSLocalizedDescriptionKey: "Audible selection group is nil for provided player item."]
        var description = "Audible selection group is nil for provided player item (NoAudioGroupLoadingError)."
    }

    struct PlayerItemNotification {
        let item: AVPlayerItem
        let name: Notification.Name
        let userInfo: [AnyHashable: Any]?

        init?(notification: Notification, originalItem: AVPlayerItem?) {
            guard let playerItem = notification.object as? AVPlayerItem, playerItem === originalItem else {
                return nil
            }
            item = playerItem
            name = notification.name
            userInfo = notification.userInfo
        }
    }
}
