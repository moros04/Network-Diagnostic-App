//
//  NetworkMonitor.swift
//  CST380-Project
//
//  Created by Miguel O on 3/17/26.
//

import Foundation
import Network

@Observable
class NetworkMonitor {
    
    var isConnected: Bool = false
    var interfaceType: String = "Unknown"
    var isIPv4Available: Bool = false
    var isIPv6Available: Bool = false
    var isExpensive: Bool = false
    var isConstrained: Bool = false
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
                
                if path.usesInterfaceType(.wifi) {
                    self.interfaceType = "Wi-Fi"
                } else if path.usesInterfaceType(.cellular) {
                    self.interfaceType = "Cellular"
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self.interfaceType = "Ethernet"
                } else {
                    self.interfaceType = "Unknown"
                }
                
                self.isIPv4Available = path.supportsIPv4
                self.isIPv6Available = path.supportsIPv6
                
                self.isExpensive = path.isExpensive
                self.isConstrained = path.isConstrained
            }
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
