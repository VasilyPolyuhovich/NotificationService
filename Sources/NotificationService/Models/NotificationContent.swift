import Foundation
@preconcurrency import UserNotifications

/// Type-safe builder for notification content
@available(iOS 18.0, macOS 15.0, *)
public struct NotificationContent: Sendable {

    // MARK: - Properties

    private var _title: String?
    private var _subtitle: String?
    private var _body: String?
    private var _badge: NSNumber?
    private var _sound: UNNotificationSound?
    private var _categoryIdentifier: String?
    private var _userInfo: [String: any Sendable] = [:]
    private var _attachments: [UNNotificationAttachment] = []
    private var _threadIdentifier: String?
    private var _interruptionLevel: UNNotificationInterruptionLevel = .active

    // MARK: - Initialization

    public init() {}

    // MARK: - Builder Methods

    /// Set notification title
    public func title(_ title: String) -> Self {
        var copy = self
        copy._title = title
        return copy
    }

    /// Set notification subtitle
    public func subtitle(_ subtitle: String) -> Self {
        var copy = self
        copy._subtitle = subtitle
        return copy
    }

    /// Set notification body
    public func body(_ body: String) -> Self {
        var copy = self
        copy._body = body
        return copy
    }

    /// Set app badge number
    public func badge(_ count: Int) -> Self {
        var copy = self
        copy._badge = NSNumber(value: count)
        return copy
    }

    /// Set notification sound
    public func sound(_ sound: UNNotificationSound = .default) -> Self {
        var copy = self
        copy._sound = sound
        return copy
    }

    /// Set category identifier
    public func category(_ identifier: String) -> Self {
        var copy = self
        copy._categoryIdentifier = identifier
        return copy
    }

    /// Set category using NotificationCategory
    public func category(_ category: NotificationCategory) -> Self {
        var copy = self
        copy._categoryIdentifier = category.identifier
        return copy
    }

    /// Add user info dictionary
    public func userInfo(_ userInfo: [String: any Sendable]) -> Self {
        var copy = self
        copy._userInfo = userInfo
        return copy
    }

    /// Add single user info value
    public func userInfo(key: String, value: any Sendable) -> Self {
        var copy = self
        copy._userInfo[key] = value
        return copy
    }

    /// Add attachments
    public func attachments(_ attachments: [UNNotificationAttachment]) -> Self {
        var copy = self
        copy._attachments = attachments
        return copy
    }

    /// Set thread identifier for grouping
    public func threadIdentifier(_ identifier: String) -> Self {
        var copy = self
        copy._threadIdentifier = identifier
        return copy
    }

    /// Set interruption level (iOS 15+)
    public func interruptionLevel(_ level: UNNotificationInterruptionLevel) -> Self {
        var copy = self
        copy._interruptionLevel = level
        return copy
    }

    // MARK: - Conversion

    /// Convert to UNMutableNotificationContent
    internal func toUNContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()

        if let title = _title {
            content.title = title
        }
        if let subtitle = _subtitle {
            content.subtitle = subtitle
        }
        if let body = _body {
            content.body = body
        }
        if let badge = _badge {
            content.badge = badge
        }
        if let sound = _sound {
            content.sound = sound
        }
        if let categoryIdentifier = _categoryIdentifier {
            content.categoryIdentifier = categoryIdentifier
        }
        if !_userInfo.isEmpty {
            content.userInfo = _userInfo
        }
        if !_attachments.isEmpty {
            content.attachments = _attachments
        }
        if let threadIdentifier = _threadIdentifier {
            content.threadIdentifier = threadIdentifier
        }

        content.interruptionLevel = _interruptionLevel

        return content
    }
}
