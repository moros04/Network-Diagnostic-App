//
//  LatencyMonitor.swift
//  CST380-Project
//
//  Created by Miguel O on 3/17/26.
//

import Foundation

@Observable
class LatencyMonitor {
    
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
    
    
}
