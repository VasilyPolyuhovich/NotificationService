import Foundation
@preconcurrency import UserNotifications

/// Example: Meditation reminder with alarm-like features
/// Ensures user doesn't miss morning meditation
@available(iOS 18.0, macOS 15.0, *)
public enum MeditationReminderExample {

    // MARK: - Alarm Features for Meditation

    /// Creates meditation reminder with maximum visibility
    ///
    /// Mechanisms to ensure user doesn't miss the notification:
    /// 1. **Critical Alert** - bypasses Do Not Disturb and silent mode
    /// 2. **Time Sensitive** - shows as high priority notification
    /// 3. **Repeating Daily** - automatic scheduling every day
    /// 4. **Custom Sound** - unique sound for meditation
    /// 5. **Snooze Action** - allow postponing for 5/10 minutes
    /// 6. **Multiple Reminders** - notification chain (5 min before, at time, 5 min after)
    @MainActor
    public static func setupMeditationAlarm(hour: Int, minute: Int) async throws {
        let manager = NotificationManager.shared

        // 1. Register custom category with snooze actions
        let meditationCategory = NotificationCategory(
            identifier: "MEDITATION_ALARM",
            actions: [
                NotificationAction(
                    identifier: "START_MEDITATION",
                    title: "🧘‍♂️ Start Now",
                    options: [.foreground],
                    icon: UNNotificationActionIcon(systemImageName: "figure.mind.and.body")
                ),
                NotificationAction(
                    identifier: "SNOOZE_5MIN",
                    title: "Snooze 5 min",
                    options: []
                ),
                NotificationAction(
                    identifier: "SNOOZE_10MIN",
                    title: "Snooze 10 min",
                    options: []
                ),
                NotificationAction(
                    identifier: "SKIP_TODAY",
                    title: "Skip Today",
                    options: [.destructive]
                )
            ]
        )

        manager.registerCategory(meditationCategory)

        // 2. Request permission with critical alerts
        _ = try await manager.requestPermission(
            options: [.alert, .sound, .badge, .criticalAlert]
        )

        // 3. Schedule notification chain
        try await scheduleNotificationChain(hour: hour, minute: minute, category: meditationCategory)

        // 4. Setup action handlers
        setupActionHandlers(manager: manager, hour: hour, minute: minute)
    }

    // MARK: - Notification Chain

    /// Schedules multiple notifications to ensure visibility
    @MainActor
    private static func scheduleNotificationChain(
        hour: Int,
        minute: Int,
        category: NotificationCategory
    ) async throws {
        let manager = NotificationManager.shared

        // Main notification (critical alert)
        let mainContent = NotificationContent()
            .title("🧘‍♂️ Time for Morning Meditation")
            .body("Your daily mindfulness practice awaits")
            .category(category)
            .sound(.defaultCriticalSound(withAudioVolume: 1.0))
            .interruptionLevel(.timeSensitive)
            .badge(1)
            .userInfo(key: "type", value: "main")

        let mainRequest = NotificationRequest(
            identifier: "meditation-main",
            content: mainContent,
            trigger: .daily(hour: hour, minute: minute)
        )

        try await manager.schedule(mainRequest)

        // Pre-reminder (5 minutes before)
        let preContent = NotificationContent()
            .title("Meditation in 5 minutes")
            .body("Prepare your meditation space")
            .sound(.default)
            .interruptionLevel(.active)
            .userInfo(key: "type", value: "pre-reminder")

        let preRequest = NotificationRequest(
            identifier: "meditation-pre",
            content: preContent,
            trigger: .daily(hour: hour, minute: minute - 5)
        )

        try await manager.schedule(preRequest)

        // Follow-up (5 minutes after, if not opened)
        let followUpContent = NotificationContent()
            .title("Don't forget your meditation!")
            .body("Just 10 minutes for your wellbeing")
            .category(category)
            .sound(.defaultCriticalSound(withAudioVolume: 0.8))
            .interruptionLevel(.timeSensitive)
            .userInfo(key: "type", value: "follow-up")

        let followUpRequest = NotificationRequest(
            identifier: "meditation-followup",
            content: followUpContent,
            trigger: .daily(hour: hour, minute: minute + 5)
        )

        try await manager.schedule(followUpRequest)
    }

    // MARK: - Action Handlers

    @MainActor
    private static func setupActionHandlers(
        manager: NotificationManager,
        hour: Int,
        minute: Int
    ) {
        // Handle custom actions
        manager.onCustomAction { response in
            switch response.actionIdentifier {
            case "START_MEDITATION":
                print("✅ Starting meditation session")
                await manager.clearBadge()
                // Navigate to meditation screen

            case "SNOOZE_5MIN":
                print("⏰ Snoozed for 5 minutes")
                try? await scheduleSnoozedNotification(delay: 300) // 5 min

            case "SNOOZE_10MIN":
                print("⏰ Snoozed for 10 minutes")
                try? await scheduleSnoozedNotification(delay: 600) // 10 min

            case "SKIP_TODAY":
                print("❌ Skipped for today")
                await MainActor.run { manager.removeAllPending() }

            default:
                break
            }
        }

        // Handle notification tap
        manager.onNotificationTap { response in
            print("📱 Notification tapped - opening meditation")
            await manager.clearBadge()
            // Navigate to meditation screen
        }
    }

    // MARK: - Snooze

    @MainActor
    private static func scheduleSnoozedNotification(delay: TimeInterval) async throws {
        let content = NotificationContent()
            .title("🧘‍♂️ Meditation Time")
            .body("Ready for your practice?")
            .sound(.defaultCriticalSound(withAudioVolume: 1.0))
            .interruptionLevel(.timeSensitive)

        let request = NotificationRequest.delayed(
            identifier: "meditation-snooze",
            content: content,
            delay: delay
        )

        try await NotificationManager.shared.schedule(request)
    }

    // MARK: - Additional Features

    /// Enable smart snooze based on user habits
    /// (can track when user typically starts meditation)
    public static func enableSmartReminders() {
        // TODO: Implement ML-based optimal timing
        // Analyze when user typically responds to notifications
        // Adjust timing accordingly
    }

    /// Gentle wake-up sequence (progressive volume)
    public static func scheduleGentleWakeup(hour: Int, minute: Int) async throws {
        // Schedule notifications with increasing volume
        // Start 15 min before with quiet sound
        // Gradually increase volume
        // Final notification at target time with full volume
    }
}

// MARK: - Usage

/*
 // In your app setup:

 Task {
     do {
         // Setup meditation alarm for 7:00 AM
         try await MeditationReminderExample.setupMeditationAlarm(
             hour: 7,
             minute: 0
         )

         print("✅ Meditation reminder configured")
     } catch {
         print("❌ Failed to setup: \(error)")
     }
 }
 */
