//
//  LatencyMonitor.swift
//  CST380-Project
//
//  Created by Miguel O on 3/17/26.
//

import Foundation
import SwiftData

// LatencyMonitor measures network latency by firing repeated HTTP requests
// to a target host and recording how long each one takes to return.
// It calculates avg RTT, jitter, p95 latency, and packet loss in real time.
@Observable
class LatencyMonitor {
    
    // These update automatically after each ping and are read by the UI
    
    var modelContext: ModelContext?   // SwiftData context for saving completed test results
    var measurements: [Double] = []  // Raw RTT values in milliseconds for each ping
    var averageRTT: Double = 0       // Mean RTT across all successful pings
    var jitter: Double = 0           // Average variation between consecutive RTT values
    var p95RTT: Double = 0           // 95th percentile RTT — worst case most users experience
    var packetLoss: Double = 0       // Percentage of pings that failed to get a response
    var isRunning: Bool = false      // Whether a latency test is currently in progress
        
    private var timer: Timer?                    // Fires one ping per second during a test
    private let host = "https://www.google.com"  // Target host to measure latency against
    private let totalPings = 10                  // Number of pings per test session
    private var failedPings = 0                  // Running count of failed requests
        
    // Progress as a value from 0.0 to 1.0 — used to drive a progress bar in the UI
    var progress: Double {
        let total = Double(measurements.count + failedPings)
        return total / Double(totalPings)
    }
        
    func startMeasuring() {
        // Reset all data before starting a fresh test
        measurements = []
        failedPings = 0
        isRunning = true
        
        // Fire one ping every second using a repeating timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.ping()
        }
    }

    func stopMeasuring() {
        // Invalidate the timer and mark the test as complete
        timer?.invalidate()
        timer = nil
        isRunning = false
        saveresult() // Save the completed test results to SwiftData
    }
        
    // Saves the final test results as a LatencyMeasurement record in SwiftData
    // so users can view historical test sessions in the history list
    private func saveresult() {
        guard let context = modelContext, !measurements.isEmpty else { return }
        let record = LatencyMeasurement(
            averageRTT: averageRTT,
            jitter: jitter,
            p95RTT: p95RTT,
            packetLoss: packetLoss
        )
        context.insert(record)
    }

    private func ping() {
        guard let url = URL(string: host) else { return }
        
        // Record the exact time the request is sent
        let start = Date()
        
        // URLSession fires an async HTTP request to the target host
        let task = URLSession.shared.dataTask(with: url) { _, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    // Request failed — increment failed ping count for packet loss calculation
                    self.failedPings += 1
                } else {
                    // RTT = time from send to response, multiplied by 1000 to convert to milliseconds
                    let rtt = Date().timeIntervalSince(start) * 1000
                    self.measurements.append(rtt)
                    self.calculateStats()
                }
                
                // Stop automatically once we have reached the total number of ping attempts
                if self.measurements.count + self.failedPings >= self.totalPings {
                    self.stopMeasuring()
                }
            }
        }
        task.resume() // Must call resume() to actually fire the request
    }

    private func calculateStats() {
        guard !measurements.isEmpty else { return }
        
        // Average RTT — sum of all RTT values divided by number of successful pings
        averageRTT = measurements.reduce(0, +) / Double(measurements.count)
        
        // Jitter — average absolute difference between consecutive RTT values.
        // High jitter means unstable connection quality.
        if measurements.count > 1 {
            var differences: [Double] = []
            for i in 1..<measurements.count {
                differences.append(abs(measurements[i] - measurements[i - 1]))
            }
            jitter = differences.reduce(0, +) / Double(differences.count)
        }
        
        // p95 RTT — sort measurements and take the value at the 95th percentile position.
        // This represents the worst latency that 95% of requests fall under.
        let sorted = measurements.sorted()
        let index = Int(Double(sorted.count) * 0.95)
        p95RTT = sorted[min(index, sorted.count - 1)]
        
        // Packet loss — failed pings as a percentage of total ping attempts
        let total = measurements.count + failedPings
        packetLoss = total > 0 ? (Double(failedPings) / Double(total)) * 100 : 0
    }
    
}
