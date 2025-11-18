import Foundation
import UserNotifications
import Observation

/// Manages user notifications, permissions, and scheduling
@Observable
@MainActor
public final class NotificationManager: NSObject, Sendable {

    // MARK: - Singleton

    public static let shared = NotificationManager()

    // MARK: - Properties

    private let notificationCenter: UNUserNotificationCenter
    private let delegate: NotificationDelegate

    /// Current authorization status
    public private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    /// Whether notifications are enabled
    public var isAuthorized: Bool {
        authorizationStatus == .authorized || authorizationStatus == .provisional
    }

    // MARK: - Initialization

    private override init() {
        self.notificationCenter = UNUserNotificationCenter.current()
        self.delegate = NotificationDelegate()
        super.init()

        notificationCenter.delegate = delegate
    }

    // MARK: - Permission Management

    /// Request notification permissions
    /// - Parameter options: Authorization options (default: alert, sound, badge)
    /// - Returns: Whether permission was granted
    @discardableResult
    public func requestPermission(
        options: UNAuthorizationOptions = [.alert, .sound, .badge]
    ) async throws -> Bool {
        let granted = try await notificationCenter.requestAuthorization(options: options)
        await updateAuthorizationStatus()
        return granted
    }

    /// Check current authorization status
    public func checkAuthorizationStatus() async {
        await updateAuthorizationStatus()
    }

    private func updateAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    // MARK: - Notification Scheduling

    /// Schedule a notification
    /// - Parameter request: Notification request to schedule
    public func schedule(_ request: NotificationRequest) async throws {
        let unRequest = try request.toUNNotificationRequest()
        try await notificationCenter.add(unRequest)
    }

    /// Schedule multiple notifications
    /// - Parameter requests: Array of notification requests
    public func scheduleMultiple(_ requests: [NotificationRequest]) async throws {
        for request in requests {
            try await schedule(request)
        }
    }

    /// Remove pending notification by identifier
    /// - Parameter identifier: Notification identifier
    public func removePending(identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    /// Remove all pending notifications
    public func removeAllPending() {
        notificationCenter.removeAllPendingNotificationRequests()
    }

    /// Remove delivered notification by identifier
    /// - Parameter identifier: Notification identifier
    public func removeDelivered(identifier: String) {
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
    }

    /// Remove all delivered notifications
    public func removeAllDelivered() {
        notificationCenter.removeAllDeliveredNotifications()
    }

    // MARK: - Query Notifications

    /// Get all pending notification requests
    public func getPendingRequests() async -> [UNNotificationRequest] {
        await notificationCenter.pendingNotificationRequests()
    }

    /// Get all delivered notifications
    public func getDeliveredNotifications() async -> [UNNotification] {
        await notificationCenter.deliveredNotifications()
    }

    // MARK: - Badge Management

    /// Set app badge number
    /// - Parameter count: Badge count (0 to clear)
    public func setBadge(_ count: Int) {
        notificationCenter.setBadgeCount(count)
    }

    /// Clear app badge
    public func clearBadge() {
        notificationCenter.setBadgeCount(0)
    }
}
