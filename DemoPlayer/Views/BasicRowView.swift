import AVFoundation
import SwiftUI

struct BasicRowView: View {
    let title: String
    let text: String

    init(title: String, bool: Bool) {
        self.title = title
        self.text = "\(bool)"
    }

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

    init(title: String, formatIDs: [UInt32]) {
        self.title = title
        self.text = formatIDs.map { String(formatID: $0) }.joined(separator: ", ")
    }

    init(title: String, dimensions: CMVideoDimensions) {
        self.title = title
        self.text = "\(String(dimensions.width))x\(String(dimensions.height))"
    }

    init(title: String, dimensions: CGSize, significantFigures: UInt? = 0) {
        self.title = title
        let width: String
        let height: String
        if let sf = significantFigures {
            width = String(format: "%.\(sf)f", dimensions.width)
            height = String(format: "%.\(sf)f", dimensions.height)
        } else {
            width = String(Double(dimensions.width))
            height = String(Double(dimensions.height))
        }
        self.text = "\(width)x\(height)"
    }

    init(title: String, double: CMTime, significantFigures: UInt? = 3) {
        self.init(title: title, double: double.seconds, significantFigures: significantFigures)
    }

    init(title: String, double: Double, significantFigures: UInt? = 3) {
        self.title = title
        if let sf = significantFigures {
            self.text = String(format: "%.\(sf)f", double)
        } else {
            self.text = String(double)
        }
    }

    init(title: String, videoRange: AVVideoRange) {
        self.title = title
        switch videoRange {
        case .hlg: self.text = "HLG"
        case .pq: self.text = "PQ"
        case .sdr: self.text = "SDR"
        default: self.text = videoRange.rawValue
        }
    }

    init(title: String, isAtmos: [AudioFormatListItem]) {
        self.title = title
        for item in isAtmos {
            let format = String(formatID: item.mASBD.mFormatID)
            if format == "ec+3" {
                self.text = "yes (unencrypted)"
                return
            } else if format == "qc+3" {
                self.text = "yes (encrypted)"
                return
            }
        }
        self.text = "no"
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

#Preview {
    VStack(alignment: .leading) {
        BasicRowView(title: "Int", int: 42)
        BasicRowView(title: "Text", text: "Hellow, World!")
        BasicRowView(title: "Double (default sf)", double: CMTime(value: 24000, timescale: 1001))
        BasicRowView(title: "Double (no sf)", double: CMTime(value: 24000, timescale: 1001), significantFigures: nil)
        BasicRowView(title: "Double (0 sf)", double: CMTime(value: 24000, timescale: 1001), significantFigures: 0)
        BasicRowView(title: "Dimensions", dimensions: CMVideoDimensions(width: 1920, height: 1080))
        BasicRowView(title: "Format ID", formatID: CMFormatDescription.MediaSubType(string: "avc1").rawValue)
        BasicRowView(
            title: "Format IDs",
            formatIDs: [
                CMFormatDescription.MediaSubType(string: "avc1").rawValue,
                CMFormatDescription.MediaSubType(string: "aac ").rawValue
            ]
        )
        BasicRowView(title: "Video Range", videoRange: .sdr)
    }
}
