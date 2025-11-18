import Foundation
@preconcurrency import UserNotifications

/// Example: How to create and handle custom notification categories
@available(iOS 18.0, macOS 15.0, *)
public enum CustomNotificationExample {

    // MARK: - Custom Category Creation

    /// Example 1: Music player notification with custom actions
    static let musicPlayer = NotificationCategory(
        identifier: "MUSIC_PLAYER",
        actions: [
            NotificationAction(
                identifier: "PLAY_PAUSE",
                title: "Play/Pause",
                options: [],
                icon: UNNotificationActionIcon(systemImageName: "playpause.fill")
            ),
            NotificationAction(
                identifier: "SKIP_FORWARD",
                title: "Next",
                options: [],
                icon: UNNotificationActionIcon(systemImageName: "forward.fill")
            ),
            NotificationAction(
                identifier: "SKIP_BACKWARD",
                title: "Previous",
                options: [],
                icon: UNNotificationActionIcon(systemImageName: "backward.fill")
            )
        ]
    )

    /// Example 2: Timer notification with custom actions
    static let timer = NotificationCategory(
        identifier: "TIMER",
        actions: [
            NotificationAction(
                identifier: "ADD_5_MIN",
                title: "+5 min",
                options: []
            ),
            NotificationAction(
                identifier: "STOP_TIMER",
                title: "Stop",
                options: [.destructive]
            )
        ]
    )

    /// Example 3: Task reminder with complete and snooze
    static let taskReminder = NotificationCategory(
        identifier: "TASK_REMINDER",
        actions: [
            NotificationAction(
                identifier: "MARK_COMPLETE",
                title: "✓ Complete",
                options: [.foreground],
                icon: UNNotificationActionIcon(systemImageName: "checkmark.circle.fill")
            ),
            NotificationAction(
                identifier: "SNOOZE_1H",
                title: "Snooze 1h",
                options: []
            )
        ]
    )

    // MARK: - Usage Example

    /// Setup notifications in your app
    @MainActor
    static func setupExample() async {
        let manager = NotificationManager.shared

        // 1. Register custom categories
        manager.registerCategories([
            musicPlayer,
            timer,
            taskReminder
        ])

        // 2. Request permission
        _ = try? await manager.requestPermission()

        // 3. Setup action handlers
        manager.onCustomAction { response in
            print("Custom action: \(response.actionIdentifier)")

            switch response.actionIdentifier {
            case "PLAY_PAUSE":
                print("Toggle play/pause")
                // Handle music playback

            case "SKIP_FORWARD":
                print("Skip to next track")
                // Handle skip forward

            case "MARK_COMPLETE":
                print("Mark task complete")
                // Mark task as done

            case "SNOOZE_1H":
                print("Snooze for 1 hour")
                // Reschedule notification

            default:
                break
            }
        }

        // 4. Handle notification tap
        manager.onNotificationTap { response in
            print("Notification tapped: \(response.notificationIdentifier)")
            // Navigate to specific screen based on userInfo
        }
    }

    /// Schedule music player notification
    @MainActor
    static func scheduleMusicNotification() async throws {
        let content = NotificationContent()
            .title("Now Playing")
            .body("Track Name - Artist")
            .category(musicPlayer)
            .threadIdentifier("music")
            .interruptionLevel(.passive)

        let request = NotificationRequest.immediate(content: content)
        try await NotificationManager.shared.schedule(request)
    }

    /// Schedule task reminder
    @MainActor
    static func scheduleTaskReminder(title: String, delay: TimeInterval) async throws {
        let content = NotificationContent()
            .title("Task Reminder")
            .body(title)
            .category(taskReminder)
            .userInfo(key: "taskId", value: "123")
            .sound(.default)

        let request = NotificationRequest.delayed(
            content: content,
            delay: delay
        )

        try await NotificationManager.shared.schedule(request)
    }
}
