import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    private let dailySummaryIdentifier = "daily.health.summary"

    /// Requests notification authorization for alert, sound, and badge.
    public func requestAuthorization() {
        Task {
            let center = UNUserNotificationCenter.current()
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                // Logging the result on the main actor to ensure thread safety
                await MainActor.run {
                    if granted {
                        print("Notification authorization granted.")
                    } else {
                        print("Notification authorization denied.")
                    }
                }
            } catch {
                await MainActor.run {
                    print("Failed to request notification authorization: \(error.localizedDescription)")
                }
            }
        }
    }

    /// Schedules a daily notification at the specified hour and minute with a fixed identifier.
    /// If authorization is not granted, it attempts to request authorization first.
    /// - Parameters:
    ///   - hour: Hour component (0-23) of the notification time.
    ///   - minute: Minute component (0-59) of the notification time.
    public func scheduleDailySummary(hour: Int, minute: Int) {
        Task {
            let center = UNUserNotificationCenter.current()
            do {
                let settings = try await center.notificationSettings()
                if settings.authorizationStatus != .authorized {
                    // Request authorization if not authorized yet
                    let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                    if !granted {
                        await MainActor.run {
                            print("Cannot schedule notification: Authorization denied.")
                        }
                        return
                    }
                }

                // Build notification content
                let content = UNMutableNotificationContent()
                content.title = "Daily Health Summary"
                content.body = "Here's your personalized health summary for today."
                content.sound = .default

                // Create date components for trigger
                var dateComponents = DateComponents()
                dateComponents.hour = hour
                dateComponents.minute = minute
                dateComponents.second = 0

                // Create a repeating calendar trigger
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

                // Remove any pending requests with the same identifier to avoid duplicates
                center.removePendingNotificationRequests(withIdentifiers: [dailySummaryIdentifier])

                // Create the notification request
                let request = UNNotificationRequest(identifier: dailySummaryIdentifier, content: content, trigger: trigger)

                // Add the notification request
                try await center.add(request)

                await MainActor.run {
                    print("Daily summary notification scheduled at \(hour):\(String(format: "%02d", minute)).")
                }
            } catch {
                await MainActor.run {
                    print("Failed to schedule daily summary notification: \(error.localizedDescription)")
                }
            }
        }
    }

    /// Cancels the daily summary notification by removing pending and delivered notifications with the identifier.
    public func cancelDailySummary() {
        Task {
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [dailySummaryIdentifier])
            center.removeDeliveredNotifications(withIdentifiers: [dailySummaryIdentifier])
            await MainActor.run {
                print("Daily summary notification canceled.")
            }
        }
    }
}
