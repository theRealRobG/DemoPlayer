import CoreMedia
import SwiftUI

struct TracksView: View {
    @ObservedObject var events: PlayerEventsData

    var body: some View {
        let tracks = events.tracks
        List {
            Section("Audio") {
                if #available(iOS 17, *) {
                    FocusableAudioTracksView(tracks: tracks)
                } else {
                    AudioTracksView(tracks: tracks)
                }
            }
            Section("Video") {
                if #available(iOS 17, *) {
                    FocusableVideoTracksView(tracks: tracks)
                } else {
                    VideoTracksView(tracks: tracks)
                }
            }
            Section("Subtitles") {
                if #available(iOS 17, *) {
                    FocusableSubtitlesTracksView(tracks: tracks)
                } else {
                    SubtitlesTracksView(tracks: tracks)
                }
            }
            Section("Closed Captions") {
                if #available(iOS 17, *) {
                    FocusableClosedCaptionsTracksView(tracks: tracks)
                } else {
                    ClosedCaptionsTracksView(tracks: tracks)
                }
            }
        }
    }
}

extension TracksView {
    @available(iOS 17, *)
    struct FocusableAudioTracksView: View {
        let tracks: PlayerEventsData.TrackInfo
        @FocusState var isFocused: Bool

        var body: some View {
            AudioTracksView(tracks: tracks)
                .focusableWithHighlight($isFocused)
        }
    }

    @available(iOS 17, *)
    struct FocusableVideoTracksView: View {
        let tracks: PlayerEventsData.TrackInfo
        @FocusState var isFocused: Bool

        var body: some View {
            VideoTracksView(tracks: tracks)
                .focusableWithHighlight($isFocused)
        }
    }

    @available(iOS 17, *)
    struct FocusableSubtitlesTracksView: View {
        let tracks: PlayerEventsData.TrackInfo
        @FocusState var isFocused: Bool

        var body: some View {
            SubtitlesTracksView(tracks: tracks)
                .focusableWithHighlight($isFocused)
        }
    }

    @available(iOS 17, *)
    struct FocusableClosedCaptionsTracksView: View {
        let tracks: PlayerEventsData.TrackInfo
        @FocusState var isFocused: Bool

        var body: some View {
            ClosedCaptionsTracksView(tracks: tracks)
                .focusableWithHighlight($isFocused)
        }
    }

    struct AudioTracksView: View {
        let tracks: PlayerEventsData.TrackInfo

        var body: some View {
            if let audio = tracks.audioTrackInfo {
                VStack(alignment: .leading) {
                    if let absd = audio.audioStreamBasicDescription {
                        BasicRowView(title: "Audio Format", formatID: absd.mFormatID)
                        BasicRowView(title: "Sample Rate", int: absd.mSampleRate)
                    }
                    if let acl = audio.audioChannelLayout {
                        BasicRowView(title: "Channel Count", int: acl.numberOfChannels)
                    }
                    BasicRowView(title: "Atmos", isAtmos: audio.audioFormatList)
                }
            } else {
                Text("No audio track information")
            }
        }
    }

    struct VideoTracksView: View {
        let tracks: PlayerEventsData.TrackInfo

        var body: some View {
            if let video = tracks.videoTrackInfo {
                VStack(alignment: .leading) {
                    BasicRowView(title: "Video Format", formatID: video.mediaSubType.rawValue)
                    BasicRowView(title: "Dimensions", dimensions: video.dimensions)
                }
            } else {
                Text("No video track information")
            }
        }
    }

    struct SubtitlesTracksView: View {
        let tracks: PlayerEventsData.TrackInfo

        var body: some View {
            if let subtitles = tracks.subtitleTrackInfo {
                VStack(alignment: .leading) {
                    BasicRowView(title: "Subtitle Format", formatID: subtitles.mediaSubType.rawValue)
                }
            } else {
                Text("No subtitles track information")
            }
        }
    }

    struct ClosedCaptionsTracksView: View {
        let tracks: PlayerEventsData.TrackInfo

        var body: some View {
            if let captions = tracks.captionTrackInfo {
                VStack(alignment: .leading) {
                    BasicRowView(title: "Closed Captions Format", formatID: captions.mediaSubType.rawValue)
                }
            } else {
                Text("No closed captions track information")
            }
        }
    }
}
