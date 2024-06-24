import CoreMedia
import SwiftUI

struct TracksView: View {
    let tracks: PlayerEventsData.TrackInfo

    var body: some View {
        List {
            Section("Audio") {
                if let audio = tracks.audioTrackInfo {
                    VStack(alignment: .leading) {
                        if let absd = audio.audioStreamBasicDescription {
                            RowView(title: "Audio Format", formatID: absd.mFormatID)
                            RowView(title: "Sample Rate", int: absd.mSampleRate)
                        }
                        if let acl = audio.audioChannelLayout {
                            RowView(title: "Channel Count", int: acl.numberOfChannels)
                        }
                    }
                } else {
                    Text("No audio track information")
                }
            }
            Section("Video") {
                if let video = tracks.videoTrackInfo {
                    VStack(alignment: .leading) {
                        RowView(title: "Video Format", formatID: video.mediaSubType.rawValue)
                        RowView(title: "Dimensions", dimensions: video.dimensions)
                    }
                } else {
                    Text("No video track information")
                }
            }
            Section("Subtitles") {
                if let subtitles = tracks.subtitleTrackInfo {
                    let _ = print("\(subtitles)")
                    VStack(alignment: .leading) {
                        RowView(title: "Subtitle Format", formatID: subtitles.mediaSubType.rawValue)
                    }
                } else {
                    Text("No subtitles track information")
                }
            }
            Section("Closed Captions") {
                if let captions = tracks.captionTrackInfo {
                    let _ = print("\(captions)")
                    VStack(alignment: .leading) {
                        RowView(title: "Closed Captions Format", formatID: captions.mediaSubType.rawValue)
                    }
                } else {
                    Text("No closed captions track information")
                }
            }
        }
    }
}

extension TracksView {
    struct RowView: View {
        let title: String
        let text: String

        init(title: String, text: String) {
            self.title = title
            self.text = text
        }

        init(title: String, int: Int) {
            self.title = title
            self.text = String(int)
        }

        init(title: String, int: Double) {
            self.title = title
            self.text = String(Int(int))
        }

        init(title: String, int: UInt32) {
            self.title = title
            self.text = String(Int(int))
        }

        init(title: String, formatID: UInt32) {
            self.title = title
            self.text = String(formatID: formatID)
        }

        init(title: String, dimensions: CMVideoDimensions) {
            self.title = title
            self.text = "\(String(dimensions.width))x\(String(dimensions.height))"
        }

        init(title: String, double: CMTime) {
            self.title = title
            self.text = "\(double.seconds)"
        }

        var body: some View {
            HStack {
                Text(title)
                    .bold()
                Text(text)
            }
            .font(.caption)
        }
    }
}
