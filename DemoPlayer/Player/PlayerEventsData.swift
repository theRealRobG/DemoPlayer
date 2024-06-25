import AVFoundation
import SwiftUI

@MainActor
class PlayerEventsData: ObservableObject {
    @Published var messages = [Message]()
    @Published var variants = [PlayerItemEventsListener.AssetVariantInfo]()
    @Published var errors = Errors()
    @Published var tracks = TrackInfo()

    func append(message: String) {
        messages.append(Message(message: message))
    }
}

extension PlayerEventsData {
    // Using an `Identifiable` struct for messages helps with using the strings in lists. The idea was taken from this
    // Stack Overflow answer:
    // > https://stackoverflow.com/a/67977144/7039100
    struct Message: Identifiable {
        let id: UUID
        let message: String

        init(message: String) {
            self.id = UUID()
            self.message = message
        }
    }

    class Errors {
        @Published var assetLoadingError: Error?
        @Published var playerItemFatalError: Error?
        @Published var playerItemErrorLogs = [AVPlayerItemErrorLogEvent]()
    }

    struct TrackInfo {
        private(set) var videoTrackInfo: CMFormatDescription?
        private(set) var audioTrackInfo: CMFormatDescription?
        private(set) var captionTrackInfo: CMFormatDescription?
        private(set) var subtitleTrackInfo: CMFormatDescription?

        mutating func set(videoTrackInfo: CMFormatDescription?) {
            self.videoTrackInfo = videoTrackInfo
        }

        mutating func set(audioTrackInfo: CMFormatDescription?) {
            self.audioTrackInfo = audioTrackInfo
        }

        mutating func set(captionTrackInfo: CMFormatDescription?) {
            self.captionTrackInfo = captionTrackInfo
        }

        mutating func set(subtitleTrackInfo: CMFormatDescription?) {
            self.subtitleTrackInfo = subtitleTrackInfo
        }

    }
}
