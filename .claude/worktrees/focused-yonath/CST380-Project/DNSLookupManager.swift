//
//  DNSLookupManager.swift
//  CST380-Project
//
//  Resolves a domain name to its A (IPv4) and AAAA (IPv6) records
//  using the POSIX getaddrinfo API and measures how long resolution takes.
//

import Foundation
import SwiftData

@Observable
class DNSLookupManager {
    var ipv4Addresses: [String] = []
    var ipv6Addresses: [String] = []
    var resolutionTime: Double = 0  // milliseconds
    var isLooking: Bool = false
    var errorMessage: String? = nil

    var modelContext: ModelContext?

    func lookup(domain: String) {
        ipv4Addresses = []
        ipv6Addresses = []
        resolutionTime = 0
        errorMessage = nil
        isLooking = true

        DispatchQueue.global(qos: .userInitiated).async {
            let start = Date()

            var hints = addrinfo()
            hints.ai_family = AF_UNSPEC       // accept both IPv4 and IPv6
            hints.ai_socktype = SOCK_STREAM

            var result: UnsafeMutablePointer<addrinfo>? = nil
            let status = getaddrinfo(domain, nil, &hints, &result)
            let elapsed = Date().timeIntervalSince(start) * 1000

            var ipv4: [String] = []
            var ipv6: [String] = []

            if status == 0 {
                var ptr = result
                while let node = ptr {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if getnameinfo(
                        node.pointee.ai_addr,
                        node.pointee.ai_addrlen,
                        &hostname,
                        socklen_t(NI_MAXHOST),
                        nil, 0,
                        NI_NUMERICHOST
                    ) == 0 {
                        let address = String(cString: hostname)
                        switch node.pointee.ai_family {
                        case AF_INET  where !ipv4.contains(address): ipv4.append(address)
                        case AF_INET6 where !ipv6.contains(address): ipv6.append(address)
                        default: break
                        }
                    }
                    ptr = node.pointee.ai_next
                }
                freeaddrinfo(result)
            }

            DispatchQueue.main.async {
                self.isLooking = false
                self.resolutionTime = elapsed

                if ipv4.isEmpty && ipv6.isEmpty {
                    self.errorMessage = status != 0
                        ? String(cString: gai_strerror(status))
                        : "No records found for \(domain)"
                } else {
                    self.ipv4Addresses = ipv4
                    self.ipv6Addresses = ipv6
                    self.save(domain: domain, ipv4: ipv4, ipv6: ipv6, time: elapsed)
                }
            }
        }
    }

    private func save(domain: String, ipv4: [String], ipv6: [String], time: Double) {
        guard let context = modelContext else { return }
        let record = DNSLookupResult(domain: domain, ipv4Addresses: ipv4, ipv6Addresses: ipv6, resolutionTime: time)
        context.insert(record)
    }
}
