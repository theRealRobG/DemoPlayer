import Foundation

extension String {
    // This function takes a `FourCharCode` and provides the string representation. This is taken from this Gist:
    // > https://gist.github.com/patrickjuchli/d1b07f97e0ea1da5db09
    init(formatID: UInt32) {
        let cString: [CChar] = [
            CChar(formatID >> 24 & 0xFF),
            CChar(formatID >> 16 & 0xFF),
            CChar(formatID >> 8 & 0xFF),
            CChar(formatID & 0xFF),
            0
        ]
        self.init(cString: cString)
    }
}
