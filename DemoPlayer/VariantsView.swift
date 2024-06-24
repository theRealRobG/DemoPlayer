import AVFoundation
import SwiftUI

struct VariantsView: View {
    let variants: [PlayerItemEventsListener.AssetVariantInfo]

    var body: some View {
        List(variants) { assetInfo in
            let variant = assetInfo.variant
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
                                Text("Codec Types: \(c.map { String(formatID: $0) }.joined(separator: ", "))")
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
                                Text("Format IDs: \(ids.map { String(formatID: $0) }.joined(separator: ", "))")
                            }
                            maybe(assetInfo.audioRenditionInfoForCurrentMediaSelection?.channelCount) { channels in
                                Text("Channels For Selected Option: \(channels)")
                            }
                            if #available(iOS 17.0, *) {
                                maybe(assetInfo.audioRenditionInfoForCurrentMediaSelection?.isImmersive) { immersive in
                                    Text("Is Immersive For Selected Option: \(immersive)")
                                }
                                maybe(assetInfo.audioRenditionInfoForCurrentMediaSelection?.isBinaural) { binaural in
                                    Text("Is Binaural For Selected Option: \(binaural)")
                                }
                                maybe(assetInfo.audioRenditionInfoForCurrentMediaSelection?.isDownmix) { downmix in
                                    Text("Is Downmix For Selected Option: \(downmix)")
                                }
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

    private func videoRange(_ avVideoRange: AVVideoRange) -> String {
        switch avVideoRange {
        case .hlg: return "HLG"
        case .pq: return "PQ"
        case .sdr: return "SDR"
        default: return avVideoRange.rawValue
        }
    }
}
