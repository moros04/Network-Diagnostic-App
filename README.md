Network Diagnostics & Analysis Tool
A real-time iOS network diagnostics app built in Swift using only first-party Apple frameworks. The app monitors live network connectivity, measures latency and jitter, and visualizes performance data through live charts — all running on a real iPhone with no hardcoded values.

Features

Connectivity Monitor — Live network interface monitoring using NWPathMonitor. Detects Wi-Fi vs Cellular vs Ethernet, IPv4/IPv6 availability, and whether the connection is expensive or constrained
Latency Analyzer — Pings a host repeatedly using URLSession and measures RTT in milliseconds. Calculates average RTT, jitter, p95 latency, and packet loss in real time
Live Chart — Swift Charts line graph that draws each ping result as it arrives and scales dynamically
Test History — SwiftData persists every completed test session with a timestamp so you can compare results over time


Frameworks
FrameworkPurposeNetwork.frameworkLive connectivity monitoring via NWPathMonitorURLSessionHTTP requests for latency measurementSwift ChartsLive RTT line graph visualizationSwiftDataLocal persistence of test history

Requirements

iOS 17+
Xcode 16+
Swift 5


Getting Started

Clone the repo

bashgit clone https://github.com/yourname/CST380-Project.git

Open CST380-Project.xcodeproj in Xcode
Select your target device or simulator
Hit Cmd + R to build and run


Architecture
The app follows MVVM — each feature is separated into its own file so logic stays out of the views.
CST380-Project/
├── NetworkMonitor.swift       # NWPathMonitor networking logic
├── LatencyMonitor.swift       # URLSession ping logic and stats
├── ConnectivityView.swift     # Connectivity Monitor screen
├── LatencyView.swift          # Latency Analyzer screen with chart
├── LatencyMeasurement.swift   # SwiftData model
└── CST380_ProjectApp.swift    # App entry point and tab bar

Networking Concepts Covered

Network Interfaces — Wi-Fi, Cellular, Ethernet
IPv4 vs IPv6
Round Trip Time (RTT)
Jitter — variation between consecutive RTT values
p95 Latency — worst case latency 95% of requests fall under
Packet Loss — percentage of failed requests
Expensive vs Constrained connections
Threading with DispatchQueue

Course
CST380 — iOS Development
California State University, Monterey Bay — Spring 2026
