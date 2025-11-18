import Foundation
@preconcurrency import UserNotifications

/// Notification action response information
@available(iOS 18.0, macOS 15.0, *)
public struct NotificationResponse: Sendable {

    /// Action identifier that was triggered
    public let actionIdentifier: String

    /// Notification identifier
    public let notificationIdentifier: String

    /// User info from notification (use value(forKey:) to access safely)
    public let userInfo: [String: any Sendable]

    /// Notification title
    public let title: String

    /// Notification body
    public let body: String

    /// Whether this is the default tap action
    public var isDefaultAction: Bool {
        actionIdentifier == UNNotificationDefaultActionIdentifier
    }

    /// Whether notification was dismissed
    public var isDismissAction: Bool {
        actionIdentifier == UNNotificationDismissActionIdentifier
    }

    /// Get value from userInfo dictionary
    public func value<T: Sendable>(forKey key: String) -> T? {
        userInfo[key] as? T
    }

    internal init(response: UNNotificationResponse) {
        self.actionIdentifier = response.actionIdentifier
        self.notificationIdentifier = response.notification.request.identifier

        // Convert userInfo to [String: any Sendable]
        // Note: We unsafely assume values are Sendable-compatible types
        var stringUserInfo: [String: any Sendable] = [:]
        for (key, value) in response.notification.request.content.userInfo {
            if let stringKey = key as? String {
                // Unsafely bridge Any to Sendable - typical notification userInfo contains only primitive types
                stringUserInfo[stringKey] = unsafeBitCast(value, to: (any Sendable).self)
            }
        }
        self.userInfo = stringUserInfo

        self.title = response.notification.request.content.title
        self.body = response.notification.request.content.body
    }
}
