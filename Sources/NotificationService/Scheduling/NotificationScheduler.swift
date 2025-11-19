import Foundation
@preconcurrency import UserNotifications

/// Helper for batch scheduling and managing notifications
@available(iOS 18.0, macOS 15.0, *)
public struct NotificationScheduler: Sendable {

    // MARK: - Batch Operations

    /// Schedule multiple notifications at once
    @MainActor
    public static func scheduleAll(_ requests: [NotificationRequest]) async throws {
        let manager = NotificationManager.shared
        try await manager.scheduleMultiple(requests)
    }

    /// Replace all pending notifications with new ones
    @MainActor
    public static func replaceAll(with requests: [NotificationRequest]) async throws {
        let manager = NotificationManager.shared
        manager.removeAllPending()
        try await scheduleAll(requests)
    }

    // MARK: - Recurring Notifications

    /// Schedule daily notification
    @MainActor
    public static func scheduleDaily(
        identifier: NotificationIdentifier = NotificationIdentifier(),
        content: NotificationContent,
        hour: Int,
        minute: Int
    ) async throws {
        let request = NotificationRequest(
            identifier: identifier,
            content: content,
            trigger: .daily(hour: hour, minute: minute)
        )

        try await NotificationManager.shared.schedule(request)
    }

    /// Schedule weekly notification
    @MainActor
    public static func scheduleWeekly(
        identifier: NotificationIdentifier = NotificationIdentifier(),
        content: NotificationContent,
        weekday: Int,
        hour: Int,
        minute: Int
    ) async throws {
        let request = NotificationRequest(
            identifier: identifier,
            content: content,
            trigger: .weekly(weekday: weekday, hour: hour, minute: minute)
        )

        try await NotificationManager.shared.schedule(request)
    }

    // MARK: - Utility

    /// Get count of pending notifications
    @MainActor
    public static func getPendingCount() async -> Int {
        let manager = NotificationManager.shared
        let requests = await manager.getPendingRequests()
        return requests.count
    }

    /// Get count of delivered notifications
    @MainActor
    public static func getDeliveredCount() async -> Int {
        let manager = NotificationManager.shared
        let notifications = await manager.getDeliveredNotifications()
        return notifications.count
    }

    /// Check if notification with identifier exists
    @MainActor
    public static func exists(identifier: NotificationIdentifier) async -> Bool {
        let manager = NotificationManager.shared
        let requests = await manager.getPendingRequests()
        return requests.contains { $0.identifier == identifier.rawValue }
    }
}
