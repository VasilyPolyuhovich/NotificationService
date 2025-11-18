import Foundation
import UserNotifications

/// Handles notification presentation and user interactions
@available(iOS 18.0, macOS 15.0, *)
@MainActor
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, Sendable {

    // MARK: - Properties

    /// Callback for notification tap (default action)
    var onNotificationTap: (@Sendable (NotificationResponse) async -> Void)?

    /// Callback for notification dismiss
    var onNotificationDismiss: (@Sendable (NotificationResponse) async -> Void)?

    /// Callback for custom action
    var onCustomAction: (@Sendable (NotificationResponse) async -> Void)?

    /// Callback for foreground presentation (return presentation options)
    var onForegroundPresentation: (@Sendable (UNNotification) async -> UNNotificationPresentationOptions)?

    // MARK: - Presentation

    /// Called when a notification is delivered while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        // Use custom handler if provided
        if let handler = onForegroundPresentation {
            return await handler(notification)
        }

        // Default: show notification even when app is in foreground
        return [.banner, .sound, .badge]
    }

    // MARK: - Response Handling

    /// Called when user interacts with a notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let notificationResponse = NotificationResponse(response: response)

        // Handle different actions
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification
            await onNotificationTap?(notificationResponse)

        case UNNotificationDismissActionIdentifier:
            // User dismissed the notification
            await onNotificationDismiss?(notificationResponse)

        default:
            // Custom action
            await onCustomAction?(notificationResponse)
        }
    }
}
