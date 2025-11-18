import Foundation
import UserNotifications

/// Handles notification presentation and user interactions
@MainActor
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, Sendable {

    // MARK: - Presentation

    /// Called when a notification is delivered while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        // Show notification even when app is in foreground
        return [.banner, .sound, .badge]
    }

    // MARK: - Response Handling

    /// Called when user interacts with a notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        let actionIdentifier = response.actionIdentifier

        // Handle different actions
        switch actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification
            await handleDefaultAction(userInfo: userInfo)

        case UNNotificationDismissActionIdentifier:
            // User dismissed the notification
            await handleDismissAction(userInfo: userInfo)

        default:
            // Custom action
            await handleCustomAction(actionIdentifier, userInfo: userInfo)
        }
    }

    // MARK: - Action Handlers

    private func handleDefaultAction(userInfo: [AnyHashable: Any]) async {
        // TODO: Implement deep linking or navigation logic
        print("Notification tapped: \(userInfo)")
    }

    private func handleDismissAction(userInfo: [AnyHashable: Any]) async {
        print("Notification dismissed: \(userInfo)")
    }

    private func handleCustomAction(_ identifier: String, userInfo: [AnyHashable: Any]) async {
        print("Custom action '\(identifier)' triggered: \(userInfo)")
    }
}
