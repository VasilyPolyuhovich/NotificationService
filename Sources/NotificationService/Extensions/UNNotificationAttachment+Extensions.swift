import Foundation
@preconcurrency import UserNotifications

@available(iOS 18.0, macOS 15.0, *)
extension UNNotificationAttachment {

    /// Create attachment from file URL
    /// - Parameters:
    ///   - url: File URL
    ///   - options: Attachment options
    public static func create(
        from url: URL,
        options: [AnyHashable: Any]? = nil
    ) throws -> UNNotificationAttachment {
        try UNNotificationAttachment(
            identifier: UUID().uuidString,
            url: url,
            options: options
        )
    }

    /// Create image attachment
    /// - Parameter url: Image file URL
    public static func image(from url: URL) throws -> UNNotificationAttachment {
        try create(from: url, options: nil)
    }

    /// Create video attachment
    /// - Parameter url: Video file URL
    public static func video(from url: URL) throws -> UNNotificationAttachment {
        try create(from: url, options: nil)
    }

    /// Create audio attachment
    /// - Parameter url: Audio file URL
    public static func audio(from url: URL) throws -> UNNotificationAttachment {
        try create(from: url, options: nil)
    }
}
