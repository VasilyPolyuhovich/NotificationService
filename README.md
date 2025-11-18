# NotificationService

Type-safe Swift Package для управління локальними та remote push нотифікаціями в iOS додатках.

## Features

- ✅ Type-safe API для UNUserNotificationCenter
- ✅ Builder pattern для контенту нотифікацій
- ✅ Підтримка різних типів triggers (time, calendar, location)
- ✅ Async/await first
- ✅ SwiftUI integration з @Observable
- ✅ Категорії нотифікацій з custom actions
- ✅ iOS 18.0+, Swift 6.0+
- ✅ Strict Concurrency enabled

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "path/to/NotificationService", from: "1.0.0")
]
```

### Local Package (для розробки)

Додайте як local package dependency в Xcode:
1. File → Add Package Dependencies...
2. Add Local... → Оберіть папку NotificationService

## Quick Start

### 1. Setup в App

```swift
import SwiftUI
import NotificationService

@main
struct YourApp: App {
    @State private var notificationManager = NotificationManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(notificationManager)
        }
    }
}
```

### 2. Request Permission

```swift
@Environment(NotificationManager.self) private var notificationManager

Button("Enable Notifications") {
    Task {
        do {
            let granted = try await notificationManager.requestPermission()
            print("Permission granted: \(granted)")
        } catch {
            print("Error: \(error)")
        }
    }
}
```

### 3. Schedule Notification

```swift
// Проста нотифікація
let content = NotificationContent()
    .title("Reminder")
    .body("Don't forget to check your tasks!")
    .sound(.default)
    .badge(1)

let request = NotificationRequest.delayed(
    content: content,
    delay: 10 // seconds
)

try await notificationManager.schedule(request)
```

### 4. Repeating Notifications

```swift
// Щоденна нотифікація о 9:00
let content = NotificationContent()
    .title("Good Morning!")
    .body("Time to start your day")

try await NotificationScheduler.scheduleDaily(
    content: content,
    hour: 9,
    minute: 0
)
```

## Usage Examples

### Time-based Notifications

```swift
// Через 60 секунд
let trigger = NotificationTrigger.after(seconds: 60)

// В конкретний час
let date = Date().addingTimeInterval(3600)
let trigger = NotificationTrigger.at(date: date)

// Щодня о 9:30
let trigger = NotificationTrigger.daily(hour: 9, minute: 30)

// Щотижня у понеділок о 10:00
let trigger = NotificationTrigger.weekly(weekday: 2, hour: 10, minute: 0)
```

### Rich Notifications

```swift
let imageURL = Bundle.main.url(forResource: "image", withExtension: "jpg")!
let attachment = try UNNotificationAttachment.image(from: imageURL)

let content = NotificationContent()
    .title("Photo Uploaded")
    .body("Your photo has been successfully uploaded")
    .attachments([attachment])
    .threadIdentifier("photos")
    .interruptionLevel(.timeSensitive)
```

### Custom Categories & Actions

```swift
// 1. Create custom category with actions
let musicPlayer = NotificationCategory(
    identifier: "MUSIC_PLAYER",
    actions: [
        NotificationAction(
            identifier: "PLAY_PAUSE",
            title: "Play/Pause",
            options: [],
            icon: UNNotificationActionIcon(systemImageName: "playpause.fill")
        ),
        NotificationAction(
            identifier: "NEXT_TRACK",
            title: "Next",
            options: []
        )
    ]
)

// 2. Register categories
let manager = NotificationManager.shared
manager.registerCategories([musicPlayer, .reminder, .alert])

// 3. Setup action handlers
manager.onCustomAction { response in
    switch response.actionIdentifier {
    case "PLAY_PAUSE":
        // Handle play/pause
        print("Toggle playback")
    case "NEXT_TRACK":
        // Skip to next track
        print("Skip forward")
    default:
        break
    }
}

// 4. Handle notification tap
manager.onNotificationTap { response in
    // Navigate to specific screen
    print("Tapped: \(response.userInfo)")
}

// 5. Use category in notification
let content = NotificationContent()
    .title("Now Playing")
    .body("Track Name - Artist")
    .category(musicPlayer)
```

### Predefined Categories

```swift
// Available predefined categories:
- .reminder    // Complete, Snooze
- .message     // Reply
- .alert       // View, Dismiss
- .invitation  // Accept, Decline
```

### Badge Management

```swift
// Set badge
await notificationManager.setBadge(5)

// Clear badge
await notificationManager.clearBadge()
```

## Architecture

```
NotificationService/
├── Core/
│   ├── NotificationManager.swift      # Main manager (@Observable)
│   └── NotificationDelegate.swift     # Delegate handling
├── Models/
│   ├── NotificationContent.swift      # Type-safe content builder
│   ├── NotificationTrigger.swift      # Trigger types
│   ├── NotificationCategory.swift     # Predefined categories
│   └── NotificationIdentifier.swift   # Type-safe identifiers
├── Scheduling/
│   ├── NotificationRequest.swift      # Request wrapper
│   └── NotificationScheduler.swift    # Batch operations
└── Extensions/
    ├── UNNotificationSound+Extensions.swift
    └── UNNotificationAttachment+Extensions.swift
```

## Requirements

- iOS 18.0+
- Swift 6.0+
- Xcode 16.0+

## License

MIT

## Contributing

Pull requests welcome! Дотримуйтесь існуючого code style та додавайте тести для нового функціоналу.
