import Foundation
import UserNotifications

extension UNNotificationSound {

    /// Create custom notification sound from file
    /// - Parameter filename: Sound file name (including extension)
    public static func custom(_ filename: String) -> UNNotificationSound {
        UNNotificationSound(named: UNNotificationSoundName(rawValue: filename))
    }

    /// Create critical alert sound (bypasses silent mode)
    /// - Parameter filename: Sound file name (including extension)
    /// - Parameter volume: Volume level (0.0 to 1.0)
    public static func critical(_ filename: String, volume: Float = 1.0) -> UNNotificationSound {
        UNNotificationSound.defaultCritical(withAudioVolume: volume)
    }
}
