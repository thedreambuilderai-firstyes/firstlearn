import AVFoundation

/// Reads phrases aloud. Uses a Kannada voice when the device has one,
/// otherwise reads the English spelling with an Indian English voice.
///
/// This is a placeholder: the real app should play recordings by a native speaker.
final class Speaker {
    static let shared = Speaker()

    private let synthesizer = AVSpeechSynthesizer()
    private let kannadaVoice = AVSpeechSynthesisVoice(language: "kn-IN")
    private let fallbackVoice = AVSpeechSynthesisVoice(language: "en-IN")

    private init() {
        // Play even when the ringer switch is on silent, as learners expect from a lesson app.
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: .duckOthers)
    }

    var hasKannadaVoice: Bool { kannadaVoice != nil }

    func say(_ phrase: Phrase, slow: Bool = false) {
        let utterance: AVSpeechUtterance
        if let kannadaVoice {
            utterance = AVSpeechUtterance(string: phrase.kannada)
            utterance.voice = kannadaVoice
        } else {
            utterance = AVSpeechUtterance(string: phrase.romanized)
            utterance.voice = fallbackVoice
        }
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * (slow ? 0.65 : 0.85)

        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }
}
