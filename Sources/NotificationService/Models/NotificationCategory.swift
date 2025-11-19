import Foundation
@preconcurrency import UserNotifications

/// Custom notification category with actions
@available(iOS 18.0, macOS 15.0, *)
public struct NotificationCategory: Sendable, Equatable {

    public let identifier: String
    public let actions: [NotificationAction]
    public let intentIdentifiers: [String]
    public let options: UNNotificationCategoryOptions

    public init(
        identifier: String,
        actions: [NotificationAction],
        intentIdentifiers: [String] = [],
        options: UNNotificationCategoryOptions = []
    ) {
        self.identifier = identifier
        self.actions = actions
        self.intentIdentifiers = intentIdentifiers
        self.options = options
    }

    // MARK: - Conversion

    internal func toUNCategory() -> UNNotificationCategory {
        UNNotificationCategory(
            identifier: identifier,
            actions: actions.map { $0.toUNAction() },
            intentIdentifiers: intentIdentifiers,
            options: options
        )
    }
}

// MARK: - Predefined Categories

@available(iOS 18.0, macOS 15.0, *)
extension NotificationCategory {

    /// Reminder category with Complete and Snooze actions
    public static var reminder: NotificationCategory {
        NotificationCategory(
            identifier: "REMINDER",
            actions: [.complete(), .snooze()]
        )
    }

    /// Message category with Reply action
    public static var message: NotificationCategory {
        NotificationCategory(
            identifier: "MESSAGE",
            actions: [.reply()]
        )
    }

    /// Alert category with View and Dismiss actions
    public static var alert: NotificationCategory {
        NotificationCategory(
            identifier: "ALERT",
            actions: [.view(), .dismiss()]
        )
    }

    /// Invitation category with Accept and Decline actions
    public static var invitation: NotificationCategory {
        NotificationCategory(
            identifier: "INVITATION",
            actions: [.accept(), .decline()]
        )
    }
}
