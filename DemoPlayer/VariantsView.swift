import AVFoundation
import SwiftUI

struct VariantsView: View {
    let variants: [AVAssetVariant]

    var body: some View {
        List(variants) { variant in
            Section("Variant") {
                VStack(alignment: .leading) {
                    if variant.averageBitRate != nil || variant.peakBitRate != nil {
                        VStack(alignment: .leading) {
                            Text("Bitrate")
                                .font(.title)
                            maybe(variant.averageBitRate) {
                                Text("Average Bitrate: \(Int($0))")
                            }
                            maybe(variant.peakBitRate) {
                                Text("Peak Bitrate: \(Int($0))")
                            }
                        }
                        .padding(.bottom)
                    }
                    if let video = variant.videoAttributes {
                        VStack(alignment: .leading) {
                            Text("Video")
                                .font(.title)
                            maybe(video.codecTypes) { c in
                                Text("Codec Types: \(c.map { codec($0) }.joined(separator: ", "))")
                            }
                            maybe(video.nominalFrameRate) {
                                Text("Frame Rate: \($0, specifier: "%.3f")")
                            }
                            maybe(video.presentationSize) {
                                Text("Presentation Size: \(String(Int($0.width)))x\(String(Int($0.height)))")
                            }
                            maybe(video.videoRange) {
                                Text("Video Range: \(videoRange($0))")
                            }
                        }
                        .padding(.bottom)
                    }
                    if let audio = variant.audioAttributes {
                        VStack(alignment: .leading) {
                            Text("Audio")
                                .font(.title)
                            maybe(audio.formatIDs) { ids in
                                Text("Format IDs: \(ids.map { codec($0) }.joined(separator: ", "))")
                            }
                        }
                    }
                }
            }
        }
    }

    private func maybe<T>(_ t: T?, format: (T) -> some View) -> some View {
        if let t {
            return AnyView(erasing: format(t))
        } else {
            return AnyView(erasing: EmptyView())
        }
    }

    // This function takes a `FourCharCode` and provides the string representation. This is taken from this Gist:
    // > https://gist.github.com/patrickjuchli/d1b07f97e0ea1da5db09
    private func codec(_ fourCC: FourCharCode) -> String {
        let cString: [CChar] = [
            CChar(fourCC >> 24 & 0xFF),
            CChar(fourCC >> 16 & 0xFF),
            CChar(fourCC >> 8 & 0xFF),
            CChar(fourCC & 0xFF),
            0
        ]
        return String(cString: cString)
    }

    private func videoRange(_ avVideoRange: AVVideoRange) -> String {
        switch avVideoRange {
        case .hlg: return "HLG"
        case .pq: return "PQ"
        case .sdr: return "SDR"
        default: return avVideoRange.rawValue
        }
    }
}
