//
//  NetworkStatusWidget.swift
//  CST380-Project
//
//  Home-screen widget that shows live network status (connected / disconnected,
//  interface type, IPv4/IPv6 support).
//
//  ─────────────────────────────────────────────────────────────────────────
//  HOW TO ADD THIS WIDGET TO YOUR PROJECT IN XCODE
//  ─────────────────────────────────────────────────────────────────────────
//  1. In Xcode, go to File → New → Target → Widget Extension.
//     Name it "NetworkStatusWidgetExtension" and make sure
//     "Include Configuration App Intent" is unchecked.
//  2. Replace the generated Swift file with THIS file (or add this file and
//     delete the generated one).
//  3. In the widget target's Build Phases → Compile Sources, confirm this file
//     is listed there (not in the app target).
//  4. Build and run on device; add the widget from the home screen widget picker.
//  ─────────────────────────────────────────────────────────────────────────

import WidgetKit
import SwiftUI
import Network

// MARK: - Timeline Entry

struct NetworkEntry: TimelineEntry {
    let date: Date
    let isConnected: Bool
    let interfaceType: String
    let isIPv4Available: Bool
    let isIPv6Available: Bool
}

// MARK: - Timeline Provider

struct NetworkStatusProvider: TimelineProvider {

    func placeholder(in context: Context) -> NetworkEntry {
        NetworkEntry(date: .now, isConnected: true, interfaceType: "Wi-Fi",
                     isIPv4Available: true, isIPv6Available: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (NetworkEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NetworkEntry>) -> Void) {
        let entry = currentEntry()
        // Refresh every 15 minutes
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 15, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private func currentEntry() -> NetworkEntry {
        // Perform a synchronous one-shot path check for widget use.
        let monitor = NWPathMonitor()
        var path: NWPath? = nil
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "widget.network")

        monitor.pathUpdateHandler = { p in
            path = p
            monitor.cancel()
            semaphore.signal()
        }
        monitor.start(queue: queue)
        semaphore.wait()

        let connected = path?.status == .satisfied
        let interface: String = {
            if path?.usesInterfaceType(.wifi)     == true { return "Wi-Fi" }
            if path?.usesInterfaceType(.cellular) == true { return "Cellular" }
            if path?.usesInterfaceType(.wiredEthernet) == true { return "Ethernet" }
            return "Unknown"
        }()

        return NetworkEntry(
            date: .now,
            isConnected: connected,
            interfaceType: interface,
            isIPv4Available: path?.supportsIPv4 ?? false,
            isIPv6Available: path?.supportsIPv6 ?? false
        )
    }
}

// MARK: - Widget Views

struct NetworkStatusWidgetEntryView: View {
    var entry: NetworkEntry
    @Environment(\.widgetFamily) private var family

    private var statusColor: Color { entry.isConnected ? .green : .red }
    private var neonBlue:   Color { Color(red: 0.18, green: 0.78, blue: 1.0) }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.03, green: 0.03, blue: 0.08),
                         Color(red: 0.02, green: 0.05, blue: 0.12)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    Text(entry.isConnected ? "Connected" : "Offline")
                        .font(.caption.bold())
                        .foregroundStyle(statusColor)
                }

                if family != .systemSmall {
                    Label(entry.interfaceType, systemImage: interfaceIcon)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.75))

                    HStack(spacing: 8) {
                        badge("IPv4", available: entry.isIPv4Available)
                        badge("IPv6", available: entry.isIPv6Available)
                    }
                }

                Spacer()

                Text(entry.date.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private var interfaceIcon: String {
        switch entry.interfaceType {
        case "Wi-Fi":    return "wifi"
        case "Cellular": return "antenna.radiowaves.left.and.right"
        case "Ethernet": return "cable.connector"
        default:         return "network"
        }
    }

    private func badge(_ label: String, available: Bool) -> some View {
        Text(label)
            .font(.system(size: 9, weight: .semibold))
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(available ? Color.green.opacity(0.25) : Color.gray.opacity(0.2))
            )
            .foregroundStyle(available ? .green : .white.opacity(0.4))
    }
}

// MARK: - Widget Configuration

struct NetworkStatusWidget: Widget {
    let kind = "NetworkStatusWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NetworkStatusProvider()) { entry in
            NetworkStatusWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Network Status")
        .description("Shows your current network connection status.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    NetworkStatusWidget()
} timeline: {
    NetworkEntry(date: .now, isConnected: true, interfaceType: "Wi-Fi",
                 isIPv4Available: true, isIPv6Available: true)
    NetworkEntry(date: .now, isConnected: false, interfaceType: "Unknown",
                 isIPv4Available: false, isIPv6Available: false)
}
