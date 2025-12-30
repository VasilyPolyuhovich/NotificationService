import Foundation
@preconcurrency import UserNotifications

/// Notification action response information
@available(iOS 18.0, macOS 15.0, *)
public struct NotificationResponse: Sendable {

    /// Action identifier that was triggered
    public let actionIdentifier: String

    /// Notification identifier
    public let notificationIdentifier: String

    /// User info from notification (use value(forKey:) to access safely)
    public let userInfo: [String: any Sendable]

    /// Notification title
    public let title: String

    /// Notification body
    public let body: String

    /// Whether this is the default tap action
    public var isDefaultAction: Bool {
        actionIdentifier == UNNotificationDefaultActionIdentifier
    }

    /// Whether notification was dismissed
    public var isDismissAction: Bool {
        actionIdentifier == UNNotificationDismissActionIdentifier
    }

    /// Get value from userInfo dictionary
    public func value<T: Sendable>(forKey key: String) -> T? {
        userInfo[key] as? T
    }

    internal init(response: UNNotificationResponse) {
        self.actionIdentifier = response.actionIdentifier
        self.notificationIdentifier = response.notification.request.identifier

        // Convert userInfo to [String: any Sendable] safely
        var stringUserInfo: [String: any Sendable] = [:]
        for (key, value) in response.notification.request.content.userInfo {
            if let stringKey = key as? String {
                stringUserInfo[stringKey] = Self.convertToSendable(value)
            }
        }
        self.userInfo = stringUserInfo

        self.title = response.notification.request.content.title
        self.body = response.notification.request.content.body
    }
    
    /// Safely convert Any to Sendable types commonly used in notification userInfo
    private static func convertToSendable(_ value: Any) -> any Sendable {
        // Handle common primitive types
        switch value {
        case let string as String:
            return string
        case let int as Int:
            return int
        case let double as Double:
            return double
        case let float as Float:
            return float
        case let bool as Bool:
            return bool
        case let date as Date:
            return date
        case let data as Data:
            return data
        case let url as URL:
            return url
        case let uuid as UUID:
            return uuid
            
        // Handle collections recursively
        case let array as [Any]:
            return array.map { convertToSendable($0) }
        case let dict as [String: Any]:
            return dict.mapValues { convertToSendable($0) }
            
        // NSNumber bridging (from Objective-C)
        case let number as NSNumber:
            // Check if it's a boolean (NSNumber stores bools too)
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return number.boolValue
            }
            return number.doubleValue
            
        // Fallback: convert to string representation
        default:
            return String(describing: value)
        }
    }
}
