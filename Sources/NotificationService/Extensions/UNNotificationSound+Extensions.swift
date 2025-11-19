import Foundation
@preconcurrency import UserNotifications

@available(iOS 18.0, macOS 15.0, *)
extension UNNotificationSound {

    /// Create custom notification sound from file
    /// - Parameter filename: Sound file name (including extension)
    public static func custom(_ filename: String) -> UNNotificationSound {
        UNNotificationSound(named: UNNotificationSoundName(rawValue: filename))
    }

    /// Create critical alert sound (bypasses silent mode)
    /// - Parameter volume: Volume level (0.0 to 1.0)
    public static func critical(volume: Float = 1.0) -> UNNotificationSound {
        UNNotificationSound.defaultCriticalSound(withAudioVolume: volume)
    }
}
