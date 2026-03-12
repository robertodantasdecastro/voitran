import AVFoundation
import Foundation

@MainActor
final class AudioPlaybackService: NSObject {
    private var player: AVAudioPlayer?

    func play(url: URL) throws {
        player = try AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        player?.play()
    }
}
