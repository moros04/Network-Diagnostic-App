//
//  ContentView.swift
//  CST380-Project
//
//  Created by Miguel O on 3/12/26.
//

import SwiftUI

struct ContentView: View {
    @State private var monitor = NetworkMonitor()
    
    var body: some View {
        NavigationView {
            List {
                Section("Connection") {
                    StatusRow(label: "Status", value: monitor.isConnected ? "Connected" : "Disconnected", color: monitor.isConnected ? .green : .red)
                    StatusRow(label: "Interface", value: monitor.interfaceType, color: .blue)
                }
                
                Section("IP") {
                    StatusRow(label: "IPv4", value: monitor.isIPv4Available ? "Available" : "Unavailable", color: monitor.isIPv4Available ? .green : .gray)
                    StatusRow(label: "IPv6", value: monitor.isIPv6Available ? "Available" : "Unavailable", color: monitor.isIPv6Available ? .green : .gray)
                }
                
                Section("Details") {
                    StatusRow(label: "Expensive", value: monitor.isExpensive ? "Yes" : "No", color: monitor.isExpensive ? .orange : .green)
                    StatusRow(label: "Constrained", value: monitor.isConstrained ? "Yes" : "No", color: monitor.isConstrained ? .orange : .green)
                }
            }
            .navigationTitle("Network Monitor")
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
