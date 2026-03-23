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
    var body: some Scene {
        WindowGroup {
            TabView {
                ConnectivityView()
                    .tabItem {
                        Label("Network", systemImage: "wifi")
                    }
                
                LatencyView()
                    .tabItem {
                        Label("Latency", systemImage: "speedometer")
                    }
            }
            .modelContainer(for: LatencyMeasurement.self)
        }
    }
}

