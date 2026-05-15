# 📡 Network Diagnostics & Analysis Tool

A real-time iOS network diagnostics app built in Swift using only first-party Apple frameworks. The app monitors live network
connectivity, measures latency and jitter, resolves DNS records, and calculates IPv4 subnets — all running on a real iPhone  
with no hardcoded values.
  
---

## ✨ Features

- 🔵 **Connectivity Monitor** — Live network interface monitoring using `NWPathMonitor`. Detects Wi-Fi vs Cellular vs
Ethernet, IPv4/IPv6 availability, and whether the connection is expensive or constrained
- 📊 **Latency Analyzer** — Pings a host repeatedly using `URLSession` and measures RTT in milliseconds. Calculates average
RTT, jitter, p95 latency, and packet loss in real time
- 🌐 **DNS Lookup Tool** — Resolves any domain name to its A (IPv4) and AAAA (IPv6) records using the POSIX `getaddrinfo` API.
 Measures resolution time in milliseconds and keeps a searchable history of past lookups
- 🔢 **Subnet Calculator** — Pure-Swift IPv4 subnetting tool. Enter any address and CIDR prefix to instantly derive the
network address, broadcast address, subnet mask, usable host range, and total address count
- 📈 **Live Chart** — Swift Charts line graph that draws each ping result as it arrives and scales dynamically
- 🗂 **Test History** — SwiftData persists completed latency sessions and DNS lookups with timestamps so you can compare
results over time

---

## 🛠 Frameworks

| Framework | Purpose |
|---|---|
| `Network.framework` | Live connectivity monitoring via `NWPathMonitor` |
| `URLSession` | HTTP requests for latency measurement |
| `Swift Charts` | Live RTT line graph visualization |
| `SwiftData` | Local persistence of latency history and DNS lookup history |
| `POSIX (getaddrinfo)` | Low-level DNS resolution for A and AAAA records |

---

## 📋 Requirements

- iOS 17+
- Xcode 16+
- Swift 5

---

## 🚀 Getting Started

1. Clone the repo
```bash
git clone https://github.com/moros04/CST380-Project.git
2. Open CST380-Project.xcodeproj in Xcode
3. Select your target device or simulator
4. Hit Cmd + R to build and run 

---
🏗 Architecture

The app follows MVVM — each feature is separated into its own file so logic stays out of the views.

CST380-Project/
├── NetworkMonitor.swift       # NWPathMonitor networking logic
├── LatencyMonitor.swift       # URLSession ping logic and stats
├── DNSLookupManager.swift     # POSIX getaddrinfo DNS resolution logic
├── ConnectivityView.swift     # Connectivity Monitor screen
├── LatencyView.swift          # Latency Analyzer screen with chart
├── DNSLookupView.swift        # DNS Lookup Tool screen with history
├── SubnettingView.swift       # IPv4 Subnet Calculator screen
├── LatencyMeasurement.swift   # SwiftData model for latency sessions
├── DNSLookupResult.swift      # SwiftData model for DNS lookup history
└── CST380_ProjectApp.swift    # App entry point and tab bar

---
🌐 Networking Concepts Covered

- Network Interfaces — Wi-Fi, Cellular, Ethernet
- IPv4 vs IPv6
- Round Trip Time (RTT)
- Jitter — variation between consecutive RTT values
- p95 Latency — worst-case latency that 95% of requests fall under
- Packet Loss — percentage of failed requests
- DNS Resolution — mapping domain names to IP addresses via A and AAAA records
- IPv4 Subnetting — CIDR notation, subnet masks, network/broadcast addresses, usable host ranges
- Expensive vs Constrained connections
- Threading with DispatchQueue

---
👥 Team

┌──────────────────┬──────────────────────────────────────────────────────────────────────────────────────────────┐
│       Name       │                                             Role                                             │
├──────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────┤
│ Miguel Oros      │ Networking — NetworkMonitor, LatencyMonitor, DNSLookupManager, ConnectivityView, LatencyView │
├──────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────┤
│ Liliana Saavedra │ Data — SwiftData models and persistence                                                      │
├──────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────┤
│ Joceline Cortez  │ UI & Styling — ConnectivityView and LatencyView polish                                       │
├──────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────┤
│ Athena Lopez     │ Integration — Testing, documentation, presentation                                           │
└──────────────────┴──────────────────────────────────────────────────────────────────────────────────────────────┘

---
🎓 Course

CST380 — Special Topics in iOS Development
California State University, Monterey Bay — Spring 2026
```
