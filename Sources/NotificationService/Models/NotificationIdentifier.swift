import Foundation

/// Type-safe notification identifiers
public struct NotificationIdentifier: Sendable, Hashable {

    public let rawValue: String

    public init(_ value: String) {
        self.rawValue = value
    }

    public init() {
        self.rawValue = UUID().uuidString
    }
}

// MARK: - ExpressibleByStringLiteral

extension NotificationIdentifier: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}

// MARK: - CustomStringConvertible

extension NotificationIdentifier: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}
