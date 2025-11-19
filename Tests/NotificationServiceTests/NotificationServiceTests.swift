import XCTest
@testable import NotificationService

final class NotificationServiceTests: XCTestCase {

    // MARK: - NotificationContent Tests

    func testNotificationContentBuilder() {
        let content = NotificationContent()
            .title("Test Title")
            .body("Test Body")
            .badge(5)
            .sound(.default)

        let unContent = content.toUNContent()

        XCTAssertEqual(unContent.title, "Test Title")
        XCTAssertEqual(unContent.body, "Test Body")
        XCTAssertEqual(unContent.badge, 5)
        XCTAssertNotNil(unContent.sound)
    }

    func testNotificationContentWithUserInfo() {
        let userInfo: [AnyHashable: Any] = ["key": "value"]
        let content = NotificationContent()
            .title("Test")
            .userInfo(userInfo)

        let unContent = content.toUNContent()

        XCTAssertEqual(unContent.userInfo["key"] as? String, "value")
    }

    // MARK: - NotificationIdentifier Tests

    func testNotificationIdentifierCreation() {
        let identifier = NotificationIdentifier("test-id")
        XCTAssertEqual(identifier.rawValue, "test-id")
    }

    func testNotificationIdentifierRandomCreation() {
        let identifier1 = NotificationIdentifier()
        let identifier2 = NotificationIdentifier()

        XCTAssertNotEqual(identifier1.rawValue, identifier2.rawValue)
    }

    // MARK: - NotificationTrigger Tests

    func testTimeIntervalTrigger() {
        let trigger = NotificationTrigger.after(seconds: 60)

        if case .timeInterval(let interval, let repeats) = trigger {
            XCTAssertEqual(interval, 60)
            XCTAssertFalse(repeats)
        } else {
            XCTFail("Expected timeInterval trigger")
        }
    }

    func testDailyTrigger() {
        let trigger = NotificationTrigger.daily(hour: 9, minute: 30)

        if case .calendar(let components, let repeats) = trigger {
            XCTAssertEqual(components.hour, 9)
            XCTAssertEqual(components.minute, 30)
            XCTAssertTrue(repeats)
        } else {
            XCTFail("Expected calendar trigger")
        }
    }

    // MARK: - NotificationRequest Tests

    func testNotificationRequestCreation() throws {
        let content = NotificationContent()
            .title("Test")
            .body("Test Body")

        let request = NotificationRequest.immediate(
            identifier: "test",
            content: content
        )

        XCTAssertEqual(request.identifier.rawValue, "test")
        XCTAssertNil(request.trigger)

        let unRequest = try request.toUNNotificationRequest()
        XCTAssertEqual(unRequest.identifier, "test")
        XCTAssertEqual(unRequest.content.title, "Test")
        XCTAssertNil(unRequest.trigger)
    }

    func testDelayedNotificationRequest() throws {
        let content = NotificationContent()
            .title("Delayed")

        let request = NotificationRequest.delayed(
            content: content,
            delay: 10
        )

        XCTAssertNotNil(request.trigger)
    }
}
