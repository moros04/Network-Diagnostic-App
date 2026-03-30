import Foundation
import Network

// NetworkMonitor uses Apple's Network.framework to observe the device's
// network path in real time. It runs on a background thread and publishes
// updates to the UI whenever the network state changes.
@Observable
class NetworkMonitor {
    
    // These properties are observed by the UI and update automatically
    // when the network path changes
    
    var isConnected: Bool = false        // Whether the device has an active connection
    var interfaceType: String = "Unknown" // Wi-Fi, Cellular, Ethernet, or Unknown
    var isIPv4Available: Bool = false    // Whether IPv4 is supported on this path
    var isIPv6Available: Bool = false    // Whether IPv6 is supported on this path
    var isExpensive: Bool = false        // True for cellular — costs money/battery
    var isConstrained: Bool = false      // True when Low Data Mode is enabled
    
    // NWPathMonitor is the core Apple API that watches the network path
    private let monitor = NWPathMonitor()
    
    // A dedicated background queue so network monitoring doesn't block the UI
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    init() {
        startMonitoring()
    }
        
    func startMonitoring() {
        // pathUpdateHandler is a closure that fires every time the network changes.
        // Apple calls this automatically — no polling or timers needed.
        monitor.pathUpdateHandler = { path in
            
            // Jump to the main thread before updating any UI-bound properties.
            // iOS requires all UI updates to happen on the main thread.
            DispatchQueue.main.async {
                
                // path.status == .satisfied means the device has a usable connection
                self.isConnected = path.status == .satisfied
                
                // Check which interface type is active and set a human-readable label
                if path.usesInterfaceType(.wifi) {
                    self.interfaceType = "Wi-Fi"
                } else if path.usesInterfaceType(.cellular) {
                    self.interfaceType = "Cellular"
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self.interfaceType = "Ethernet"
                } else {
                    self.interfaceType = "Unknown"
                }
                
                // Read IP version support from the NWPath object
                self.isIPv4Available = path.supportsIPv4
                self.isIPv6Available = path.supportsIPv6
                
                // Expensive = cellular data (costs money/battery)
                // Constrained = Low Data Mode is active
                self.isExpensive = path.isExpensive
                self.isConstrained = path.isConstrained
            }
        }
        
        // Start monitoring on the background queue.
        // Nothing happens until this line is called.
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        // Cancel the monitor when it is no longer needed
        monitor.cancel()
    }
}
