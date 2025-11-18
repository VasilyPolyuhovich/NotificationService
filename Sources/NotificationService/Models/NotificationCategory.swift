import Foundation
import UserNotifications

/// Predefined notification categories with actions
public enum NotificationCategory: String, Sendable, CaseIterable {

    case reminder = "REMINDER"
    case message = "MESSAGE"
    case alert = "ALERT"

    // MARK: - Actions

    /// Get actions for this category
    var actions: [UNNotificationAction] {
        switch self {
        case .reminder:
            return [
                UNNotificationAction(
                    identifier: "COMPLETE",
                    title: "Complete",
                    options: [.foreground]
                ),
                UNNotificationAction(
                    identifier: "SNOOZE",
                    title: "Snooze",
                    options: []
                )
            ]

        case .message:
            return [
                UNNotificationAction(
                    identifier: "REPLY",
                    title: "Reply",
                    options: [.foreground]
                )
            ]

        case .alert:
            return [
                UNNotificationAction(
                    identifier: "VIEW",
                    title: "View",
                    options: [.foreground]
                ),
                UNNotificationAction(
                    identifier: "DISMISS",
                    title: "Dismiss",
                    options: [.destructive]
                )
            ]
        }
    }

    // MARK: - Category Creation

    /// Create UNNotificationCategory
    func createCategory() -> UNNotificationCategory {
        UNNotificationCategory(
            identifier: rawValue,
            actions: actions,
            intentIdentifiers: [],
            options: []
        )
    }

    /// Register all categories
    public static func registerAll() {
        let categories = Set(NotificationCategory.allCases.map { $0.createCategory() })
        UNUserNotificationCenter.current().setNotificationCategories(categories)
    }
}
