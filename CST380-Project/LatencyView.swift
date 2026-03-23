//
//  LatencyView.swift
//  CST380-Project
//
//  Created by Miguel O on 3/23/26.
//

import SwiftUI

struct LatencyView: View {
    
    @State private var latencyMonitor = LatencyMonitor()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                if latencyMonitor.measurements.isEmpty {
                    Text("Press Start to begin measuring")
                        .foregroundColor(.secondary)
                } else {
                    VStack(spacing: 12) {
                        MetricRow(label: "Avg RTT", value: String(format: "%.2f", latencyMonitor.averageRTT) + " ms")
                        MetricRow(label: "Jitter", value: String(format: "%.2f", latencyMonitor.jitter) + " ms")
                        MetricRow(label: "p95 RTT", value: String(format: "%.2f", latencyMonitor.p95RTT) + " ms")
                        MetricRow(label: "Packet Loss", value: String(format: "%.2f", latencyMonitor.packetLoss) + "%")
                    }
                    .padding()
                }
                
                Button(action: {
                    if latencyMonitor.isRunning {
                        latencyMonitor.stopMeasuring()
                    } else {
                        latencyMonitor.startMeasuring()
                    }
                }) {
                    Text(latencyMonitor.isRunning ? "Stop" : "Start")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(latencyMonitor.isRunning ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Latency Analyzer")
        }
    }
}

struct MetricRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
}
