//
//  LatencyMeasurement.swift
//  CST380-Project
//
//  Created by Liliana Saavedra on 3/23/26.
//

import SwiftData
import Charts
import Foundation
//import SwiftUI


@Model
class LatencyMeasurement {
    var timestamp: Date
    var averageRTT: Double //Average round trip time
    var jitter: Double
    var p95RTT: Double
    var packetLoss: Double
    
    init(timestamp: Date = .now, averageRTT: Double, jitter: Double, p95RTT: Double, packetLoss: Double){
        self.timestamp = timestamp
        self.averageRTT = averageRTT
        self.jitter = jitter
        self.p95RTT = p95RTT
        self.packetLoss = packetLoss
    }
}
