import Foundation
import UserNotifications

/// Type-safe wrapper for notification actions
@available(iOS 18.0, macOS 15.0, *)
public struct NotificationAction: Sendable, Hashable {

    public let identifier: String
    public let title: String
    public let options: UNNotificationActionOptions
    public let icon: UNNotificationActionIcon?

    public init(
        identifier: String,
        title: String,
        options: UNNotificationActionOptions = [],
        icon: UNNotificationActionIcon? = nil
    ) {
        self.identifier = identifier
        self.title = title
        self.options = options
        self.icon = icon
    }

    // MARK: - Conversion

    internal func toUNAction() -> UNNotificationAction {
        if let icon = icon {
            return UNNotificationAction(
                identifier: identifier,
                title: title,
                options: options,
                icon: icon
            )
        } else {
            return UNNotificationAction(
                identifier: identifier,
                title: title,
                options: options
            )
        }
    }
}

// MARK: - Predefined Actions

extension NotificationAction {

    /// Complete action (foreground)
    public static func complete(title: String = "Complete") -> NotificationAction {
        NotificationAction(
            identifier: "COMPLETE",
            title: title,
            options: [.foreground]
        )
    }

    /// Snooze action (background)
    public static func snooze(title: String = "Snooze") -> NotificationAction {
        NotificationAction(
            identifier: "SNOOZE",
            title: title,
            options: []
        )
    }

    /// Reply action (foreground)
    public static func reply(title: String = "Reply") -> NotificationAction {
        NotificationAction(
            identifier: "REPLY",
            title: title,
            options: [.foreground]
        )
    }

    /// View action (foreground)
    public static func view(title: String = "View") -> NotificationAction {
        NotificationAction(
            identifier: "VIEW",
            title: title,
            options: [.foreground]
        )
    }

    /// Dismiss action (destructive)
    public static func dismiss(title: String = "Dismiss") -> NotificationAction {
        NotificationAction(
            identifier: "DISMISS",
            title: title,
            options: [.destructive]
        )
    }

    /// Accept action (foreground)
    public static func accept(title: String = "Accept") -> NotificationAction {
        NotificationAction(
            identifier: "ACCEPT",
            title: title,
            options: [.foreground]
        )
    }

    /// Decline action (destructive)
    public static func decline(title: String = "Decline") -> NotificationAction {
        NotificationAction(
            identifier: "DECLINE",
            title: title,
            options: [.destructive]
        )
    }
}
