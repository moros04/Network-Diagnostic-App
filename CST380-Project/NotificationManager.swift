//
//  NotificationManager.swift
//  CST380-Project
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    /// Request notification permission — call once at app launch.
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    /// Fire a local notification if average RTT exceeds `threshold` ms.
    func notifyIfLatencyHigh(averageRTT: Double, threshold: Double = 200.0) {
        guard averageRTT > threshold else { return }

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }

            let content = UNMutableNotificationContent()
            content.title = "High Latency Detected"
            content.body = String(format: "Average RTT of %.0f ms exceeds the %.0f ms threshold.", averageRTT, threshold)
            content.sound = .default

            let request = UNNotificationRequest(
                identifier: "latency-spike-\(Date().timeIntervalSince1970)",
                content: content,
                trigger: nil  // deliver immediately
            )
            UNUserNotificationCenter.current().add(request)
        }
    }
}
