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
    /// Using callback-based API for better compatibility with app lifecycle
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping @Sendable (UNNotificationPresentationOptions) -> Void
    ) {
        let handler = onForegroundPresentation
        
        if let handler = handler {
            Task { @MainActor in
                let options = await handler(notification)
                completionHandler(options)
            }
        } else {
            // Default: show notification even when app is in foreground
            completionHandler([.banner, .sound, .badge])
        }
    }
    
    // MARK: - Response Handling
    
    /// Called when user interacts with a notification
    /// Using callback-based API to avoid Swift concurrency thread pool issues during app lifecycle transitions
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping @Sendable () -> Void
    ) {
        let notificationResponse = NotificationResponse(response: response)
        let actionIdentifier = response.actionIdentifier
        
        let tapHandler = onNotificationTap
        let dismissHandler = onNotificationDismiss
        let customHandler = onCustomAction
        
        // Dispatch to main queue to ensure all UI-related work happens on main thread
        DispatchQueue.main.async {
            Task { @MainActor in
                switch actionIdentifier {
                case UNNotificationDefaultActionIdentifier:
                    await tapHandler?(notificationResponse)
                case UNNotificationDismissActionIdentifier:
                    await dismissHandler?(notificationResponse)
                default:
                    await customHandler?(notificationResponse)
                }
                completionHandler()
            }
        }
    }
}
