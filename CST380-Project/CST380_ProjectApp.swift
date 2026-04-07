//
//  CST380_ProjectApp.swift
//  CST380-Project
//
//  Created by Miguel O on 3/12/26.
//

import SwiftUI
import SwiftData

@main
struct CST380_ProjectApp: App {

    init() {
        NotificationManager.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                ConnectivityView()
                    .tabItem { Label("Network", systemImage: "wifi") }

                LatencyView()
                    .tabItem { Label("Latency", systemImage: "speedometer") }

                DNSLookupView()
                    .tabItem { Label("DNS", systemImage: "globe.americas.fill") }

                SubnettingView()
                    .tabItem { Label("Subnet", systemImage: "network.badge.shield.half.filled") }

                AnalyticsDashboardView()
                    .tabItem { Label("Analytics", systemImage: "chart.bar.xaxis.ascending.badge.clock") }
            }
            .modelContainer(for: [LatencyMeasurement.self, DNSLookupResult.self])
        }
    }
}
