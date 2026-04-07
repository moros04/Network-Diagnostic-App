//
//  DNSLookupResult.swift
//  CST380-Project
//

import Foundation
import SwiftData

@Model
class DNSLookupResult {
    var timestamp: Date
    var domain: String
    var ipv4Addresses: [String]
    var ipv6Addresses: [String]
    var resolutionTime: Double  // milliseconds

    init(domain: String, ipv4Addresses: [String], ipv6Addresses: [String], resolutionTime: Double) {
        self.timestamp = Date()
        self.domain = domain
        self.ipv4Addresses = ipv4Addresses
        self.ipv6Addresses = ipv6Addresses
        self.resolutionTime = resolutionTime
    }
}
