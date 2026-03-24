//
//  ContentView.swift
//  CST380-Project
//
//  Created by Miguel O on 3/12/26.
//

import SwiftUI

struct ConnectivityView: View {
    @State private var monitor = NetworkMonitor()
    @State private var selectedInfo: String? = nil
    
    let infoText: [String: String] = [
        "Status": "Shows whether your device currently has an active internet connection.",
        "Interface": "Indicates the network interface being used, such as Wi‑Fi or Cellular.",
        "IPv4": "IPv4 is the older internet addressing system. Many networks still rely on it.",
        "IPv6": "IPv6 is the newer addressing system designed to replace IPv4.",
        "Expensive": "An expensive connection is one that may result in charges, such as cellular data.",
        "Constrained": "A constrained connection limits data usage, often due to Low Data Mode."
    ]
    
    
    var body: some View {
        NavigationView {
            List {
                Section("Connection") {
                    Button {
                        selectedInfo = "Status"
                    } label: {
                        StatusRow(
                            label: "Status",
                            value: monitor.isConnected ? "Connected" : "Disconnected",
                            color: monitor.isConnected ? .green : .red
                        )
                    }
                    Button {
                        selectedInfo = "Interface"
                    } label: {
                        StatusRow(
                            label: "Interface",
                            value: monitor.interfaceType,
                            color: .blue
                        )
                    }
                }
                
                Section("IP") {
                    Button {
                        selectedInfo = "IPv4"
                    } label: {
                        StatusRow(
                            label: "IPv4",
                            value: monitor.isIPv4Available ? "Available" : "Unavailable",
                            color: monitor.isIPv4Available ? .green : .gray
                        )
                    }
                    Button {
                        selectedInfo = "IPv6"
                    } label: {
                        StatusRow(
                            label: "IPv6",
                            value: monitor.isIPv6Available ? "Available" : "Unavailable",
                            color: monitor.isIPv6Available ? .green : .gray
                        )
                    }
                }
                
                Section("Details") {
                    Button {
                        selectedInfo = "Expensive"
                    } label: {
                        StatusRow(
                            label: "Expensive",
                            value: monitor.isExpensive ? "Yes" : "No",
                            color: monitor.isExpensive ? .orange : .green
                        )
                    }
                    Button {
                        selectedInfo = "Constrained"
                    } label: {
                        StatusRow(
                            label: "Constrained",
                            value: monitor.isConstrained ? "Yes" : "No",
                            color: monitor.isConstrained ? .orange : .green
                        )
                    }
                }
            }
            .navigationTitle("Network Monitor")
        }
        .sheet(isPresented: Binding(
            get: { selectedInfo != nil },
            set: { if !$0 { selectedInfo = nil } }
        )) {
            if let item = selectedInfo {
                VStack(spacing: 20) {
                    Text(item)
                        .font(.title2)
                        .bold()
                    
                    Text(infoText[item] ?? "No information available.")
                        .padding()
                    
                    Button("Close") {
                        selectedInfo = nil
                    }
                    .padding(.top)
                }
                .padding()
            }
        }
    }
}
    
struct StatusRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.primary)
            Spacer()
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                Text(value)
                    .foregroundColor(.secondary)
            }
        }
    }
}
