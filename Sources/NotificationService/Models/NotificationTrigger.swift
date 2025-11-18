import Foundation
import UserNotifications
import CoreLocation

/// Type-safe notification trigger types
public enum NotificationTrigger: Sendable {

    /// Time interval trigger
    case timeInterval(TimeInterval, repeats: Bool = false)

    /// Calendar trigger (specific date/time)
    case calendar(DateComponents, repeats: Bool = false)

    /// Location trigger
    case location(CLLocationCoordinate2D, radius: CLLocationDistance, notifyOnEntry: Bool, notifyOnExit: Bool, repeats: Bool = false)

    // MARK: - Conversion

    /// Convert to UNNotificationTrigger
    internal func toUNTrigger() -> UNNotificationTrigger? {
        switch self {
        case .timeInterval(let interval, let repeats):
            return UNTimeIntervalNotificationTrigger(
                timeInterval: interval,
                repeats: repeats
            )

        case .calendar(let dateComponents, let repeats):
            return UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: repeats
            )

        case .location(let coordinate, let radius, let onEntry, let onExit, let repeats):
            let region = CLCircularRegion(
                center: coordinate,
                radius: radius,
                identifier: UUID().uuidString
            )
            region.notifyOnEntry = onEntry
            region.notifyOnExit = onExit

            return UNLocationNotificationTrigger(
                region: region,
                repeats: repeats
            )
        }
    }
}

// MARK: - Convenience Initializers

extension NotificationTrigger {

    /// Schedule notification after delay
    public static func after(seconds: TimeInterval) -> NotificationTrigger {
        .timeInterval(seconds, repeats: false)
    }

    /// Schedule notification at specific date
    public static func at(date: Date) -> NotificationTrigger {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        return .calendar(components, repeats: false)
    }

    /// Schedule daily notification at specific time
    public static func daily(hour: Int, minute: Int) -> NotificationTrigger {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return .calendar(components, repeats: true)
    }

    /// Schedule weekly notification
    public static func weekly(weekday: Int, hour: Int, minute: Int) -> NotificationTrigger {
        var components = DateComponents()
        components.weekday = weekday // 1 = Sunday, 7 = Saturday
        components.hour = hour
        components.minute = minute
        return .calendar(components, repeats: true)
    }
}
