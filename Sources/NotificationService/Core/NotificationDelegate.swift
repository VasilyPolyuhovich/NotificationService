import Foundation
@preconcurrency import UserNotifications

/// Handles notification presentation and user interactions
@available(iOS 18.0, macOS 15.0, *)
@MainActor
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {

    // MARK: - Properties

    /// Callback for notification tap (default action)
    nonisolated(unsafe) var onNotificationTap: (@Sendable (NotificationResponse) async -> Void)?

    /// Callback for notification dismiss
    nonisolated(unsafe) var onNotificationDismiss: (@Sendable (NotificationResponse) async -> Void)?

    /// Callback for custom action
    nonisolated(unsafe) var onCustomAction: (@Sendable (NotificationResponse) async -> Void)?

    /// Callback for foreground presentation (return presentation options)
    nonisolated(unsafe) var onForegroundPresentation: (@Sendable (UNNotification) async -> UNNotificationPresentationOptions)?

    // MARK: - Presentation

    /// Called when a notification is delivered while app is in foreground
    nonisolated func userNotificationCenter(
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
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let notificationResponse = NotificationResponse(response: response)
        let actionIdentifier = response.actionIdentifier
        
        let tapHandler = onNotificationTap
        let dismissHandler = onNotificationDismiss
        let customHandler = onCustomAction

        _ = await MainActor.run {
            Task { @MainActor in
                switch actionIdentifier {
                case UNNotificationDefaultActionIdentifier:
                    await tapHandler?(notificationResponse)
                case UNNotificationDismissActionIdentifier:
                    await dismissHandler?(notificationResponse)
                default:
                    await customHandler?(notificationResponse)
                }
            }
        }
    }
}
