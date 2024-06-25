import AVFoundation
import SwiftUI

struct VariantsView: View {
    @ObservedObject var events: PlayerEventsData

    var body: some View {
        let variants = events.variants
        List(variants) { assetInfo in
            let variant = assetInfo.variant
            Section("Variant") {
                if #available(iOS 17, *) {
                    FocusableVariantView(variant: variant, assetInfo: assetInfo)
                } else {
                    VariantView(variant: variant, assetInfo: assetInfo)
                }
            }
        }
    }
}

extension VariantsView {
    @available(iOS 17, *)
    struct FocusableVariantView: View {
        let variant: AVAssetVariant
        let assetInfo: PlayerItemEventsListener.AssetVariantInfo
        @FocusState var isFocused: Bool

        var body: some View {
            VariantView(variant: variant, assetInfo: assetInfo)
                .focusableWithHighlight($isFocused)
        }
    }

    struct VariantView: View {
        let variant: AVAssetVariant
        let assetInfo: PlayerItemEventsListener.AssetVariantInfo

        var body: some View {
            VStack(alignment: .leading) {
                if variant.averageBitRate != nil || variant.peakBitRate != nil {
                    VStack(alignment: .leading) {
                        Text("Bitrate")
                            .font(.subheadline)
                        maybe(variant.averageBitRate) {
                            BasicRowView(title: "Average Bitrate", int: $0)
                        }
                        maybe(variant.peakBitRate) {
                            BasicRowView(title: "Peak Bitrate", int: $0)
                        }
                    }
                    .padding(.bottom)
                }
                if let video = variant.videoAttributes {
                    VStack(alignment: .leading) {
                        Text("Video")
                            .font(.subheadline)
                        maybe(video.codecTypes) { codecs in
                            BasicRowView(title: "Codec Types", formatIDs: codecs)
                        }
                        maybe(video.nominalFrameRate) {
                            BasicRowView(title: "Frame Rate", double: $0)
                        }
                        maybe(video.presentationSize) {
                            BasicRowView(title: "Presentation Size", dimensions: $0)
                        }
                        maybe(video.videoRange) {
                            BasicRowView(title: "Video Range", videoRange: $0)
                        }
                    }
                    .padding(.bottom)
                }
                if let audio = variant.audioAttributes {
                    VStack(alignment: .leading) {
                        Text("Audio")
                            .font(.subheadline)
                        maybe(audio.formatIDs) { ids in
                            BasicRowView(title: "Codec Types", formatIDs: ids)
                        }
                        maybe(assetInfo.audioRenditionInfoForCurrentMediaSelection?.channelCount) { channels in
                            BasicRowView(title: "Channels For Selected Option", int: channels)
                        }
                        if #available(iOS 17.0, tvOS 17, *) {
                            maybe(assetInfo.audioRenditionInfoForCurrentMediaSelection?.isImmersive) { immersive in
                                BasicRowView(title: "Is Immersive For Selected Option", bool: immersive)
                            }
                            maybe(assetInfo.audioRenditionInfoForCurrentMediaSelection?.isBinaural) { binaural in
                                BasicRowView(title: "Is Binaural For Selected Option", bool: binaural)
                            }
                            maybe(assetInfo.audioRenditionInfoForCurrentMediaSelection?.isDownmix) { downmix in
                                BasicRowView(title: "Is Downmix For Selected Option", bool: downmix)
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
    }
}
