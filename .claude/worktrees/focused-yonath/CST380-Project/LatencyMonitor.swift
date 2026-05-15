//
//  LatencyMonitor.swift
//  CST380-Project
//
//  Created by Miguel O on 3/17/26.
//

import Foundation
import SwiftData

@Observable
class LatencyMonitor {
    
    var modelContext: ModelContext?
    var measurements: [Double] = []
    var averageRTT: Double = 0
    var jitter: Double = 0
    var p95RTT: Double = 0
    var packetLoss: Double = 0
    var isRunning: Bool = false
    
    private var timer: Timer?
    private let host = "https://www.google.com"
    private let totalPings = 10
    private var failedPings = 0
    
    var progress: Double {
        let total = Double(measurements.count + failedPings)
        return total / Double(totalPings)
    }
    
    func startMeasuring() {
        measurements = []
        failedPings = 0
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.ping()
        }
    }

    func stopMeasuring() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        saveresult() //Save data when test is finished
    }
    
    // Saves the completed test to SwiftData and fires a notification if RTT is high
    private func saveresult() {
        guard let context = modelContext, !measurements.isEmpty else { return }
        let record = LatencyMeasurement(
            averageRTT: averageRTT,
            jitter: jitter,
            p95RTT: p95RTT,
            packetLoss: packetLoss
        )
        context.insert(record)
        NotificationManager.shared.notifyIfLatencyHigh(averageRTT: averageRTT)
    }

    private func ping() {
        guard let url = URL(string: host) else { return }
        
        let start = Date()
        
        let task = URLSession.shared.dataTask(with: url) { _, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    self.failedPings += 1
                } else {
                    let rtt = Date().timeIntervalSince(start) * 1000
                    self.measurements.append(rtt)
                    self.calculateStats()
                }
                
                if self.measurements.count + self.failedPings >= self.totalPings {
                    self.stopMeasuring()
                }
            }
        }
        task.resume()
    }

    private func calculateStats() {
        guard !measurements.isEmpty else { return }
        
        averageRTT = measurements.reduce(0, +) / Double(measurements.count)
        
        if measurements.count > 1 {
            var differences: [Double] = []
            for i in 1..<measurements.count {
                differences.append(abs(measurements[i] - measurements[i - 1]))
            }
            jitter = differences.reduce(0, +) / Double(differences.count)
        }
        
        let sorted = measurements.sorted()
        let index = Int(Double(sorted.count) * 0.95)
        p95RTT = sorted[min(index, sorted.count - 1)]
        
        let total = measurements.count + failedPings
        packetLoss = total > 0 ? (Double(failedPings) / Double(total)) * 100 : 0
    }
    
}
