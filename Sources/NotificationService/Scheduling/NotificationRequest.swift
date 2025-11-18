import Foundation
@preconcurrency import UserNotifications

/// Type-safe notification request
@available(iOS 18.0, macOS 15.0, *)
public struct NotificationRequest: Sendable {

    // MARK: - Properties

    public let identifier: NotificationIdentifier
    public let content: NotificationContent
    public let trigger: NotificationTrigger?

    // MARK: - Initialization

    public init(
        identifier: NotificationIdentifier = NotificationIdentifier(),
        content: NotificationContent,
        trigger: NotificationTrigger? = nil
    ) {
        self.identifier = identifier
        self.content = content
        self.trigger = trigger
    }

    // MARK: - Conversion

    /// Convert to UNNotificationRequest
    internal func toUNNotificationRequest() throws -> UNNotificationRequest {
        let unContent = content.toUNContent()
        let unTrigger = trigger?.toUNTrigger()

        return UNNotificationRequest(
            identifier: identifier.rawValue,
            content: unContent,
            trigger: unTrigger
        )
    }
}

// MARK: - Convenience Initializers

@available(iOS 18.0, macOS 15.0, *)
extension NotificationRequest {

    /// Create immediate notification (no trigger)
    public static func immediate(
        identifier: NotificationIdentifier = NotificationIdentifier(),
        content: NotificationContent
    ) -> NotificationRequest {
        NotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil
        )
    }

    /// Create delayed notification
    public static func delayed(
        identifier: NotificationIdentifier = NotificationIdentifier(),
        content: NotificationContent,
        delay: TimeInterval
    ) -> NotificationRequest {
        NotificationRequest(
            identifier: identifier,
            content: content,
            trigger: .after(seconds: delay)
        )
    }

    /// Create scheduled notification
    public static func scheduled(
        identifier: NotificationIdentifier = NotificationIdentifier(),
        content: NotificationContent,
        date: Date
    ) -> NotificationRequest {
        NotificationRequest(
            identifier: identifier,
            content: content,
            trigger: .at(date: date)
        )
    }
}
