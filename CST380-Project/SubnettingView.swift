//
//  SubnettingView.swift
//  CST380-Project
//
//  Pure-Swift IPv4 subnetting calculator.
//  Input an IP address and CIDR prefix (e.g. 192.168.1.0 / 24) and the view
//  derives every meaningful subnet property without any networking APIs.
//

import SwiftUI

struct SubnettingView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var ipInput: String = "192.168.1.0"
    @State private var cidrInput: String = "24"
    @State private var result: SubnetResult? = nil
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        headerCard
                        inputCard
                        if let err = errorMessage {
                            errorCard(err)
                        } else if let r = result {
                            resultsCard(r)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Subnet Calculator")
            .foregroundStyle(textColor)
        }
    }

    // ── Cards ────────────────────────────────────────────────────────────

    private var headerCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(cardFill)
                .overlay(RoundedRectangle(cornerRadius: 28).stroke(cardStroke, lineWidth: 1))
                .shadow(color: neonBlue.opacity(0.18), radius: 20)

            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(neonBlue.opacity(0.15))
                        .frame(width: 74, height: 74)
                    Image(systemName: "network.badge.shield.half.filled")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(neonBlue)
                }
                Text("Subnet Calculator")
                    .font(.title3.bold())
                    .foregroundStyle(textColor)
                Text("Derive subnet mask, host range, and broadcast address from CIDR notation")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(subtextColor)
            }
            .padding(.vertical, 28)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
    }

    private var inputCard: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Label("IP Address", systemImage: "number")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(subtextColor)

                TextField("e.g. 192.168.1.0", text: $ipInput)
                    .keyboardType(.numbersAndPunctuation)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding(12)
                    .background(inputBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(textColor)
            }

            VStack(alignment: .leading, spacing: 6) {
                Label("CIDR Prefix (0 – 32)", systemImage: "slash.circle")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(subtextColor)

                TextField("e.g. 24", text: $cidrInput)
                    .keyboardType(.numberPad)
                    .padding(12)
                    .background(inputBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(textColor)
            }

            Button(action: calculate) {
                HStack {
                    Image(systemName: "function")
                    Text("Calculate")
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [neonPurple, neonBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: neonBlue.opacity(0.25), radius: 16)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(cardFill)
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(cardStroke, lineWidth: 1))
                .shadow(color: neonPurple.opacity(0.12), radius: 16)
        )
    }

    private func resultsCard(_ r: SubnetResult) -> some View {
        VStack(spacing: 14) {
            resultRow(icon: "network",                  title: "Network Address",   value: r.networkAddress,  color: neonBlue)
            resultRow(icon: "dot.radiowaves.right",     title: "Broadcast Address", value: r.broadcastAddress, color: .orange)
            resultRow(icon: "shield.lefthalf.filled",   title: "Subnet Mask",       value: r.subnetMask,      color: neonPurple)
            resultRow(icon: "arrow.right.circle",       title: "First Usable Host", value: r.firstHost,       color: .green)
            resultRow(icon: "arrow.left.circle",        title: "Last Usable Host",  value: r.lastHost,        color: .green)
            resultRow(icon: "person.3",                 title: "Usable Hosts",      value: "\(r.usableHosts.formatted())", color: neonBlue)
            resultRow(icon: "square.grid.3x3",          title: "Total Addresses",   value: "\(r.totalAddresses.formatted())", color: neonPurple)
            resultRow(icon: "number.circle",            title: "CIDR",              value: "/\(r.prefix)",    color: .cyan)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(cardFill)
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(cardStroke, lineWidth: 1))
                .shadow(color: neonBlue.opacity(0.10), radius: 14)
        )
    }

    private func errorCard(_ message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(textColor)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.orange.opacity(0.12))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.orange.opacity(0.3), lineWidth: 1))
        )
    }

    private func resultRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.18))
                    .frame(width: 42, height: 42)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
            }
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(textColor)
            Spacer()
            Text(value)
                .font(.system(.subheadline, design: .monospaced).weight(.medium))
                .foregroundStyle(subtextColor)
        }
        .padding(.vertical, 6)
    }

    // ── Calculation logic ────────────────────────────────────────────────

    private func calculate() {
        errorMessage = nil
        result = nil

        guard let cidr = Int(cidrInput.trimmingCharacters(in: .whitespaces)),
              (0...32).contains(cidr) else {
            errorMessage = "CIDR prefix must be an integer between 0 and 32."
            return
        }

        let parts = ipInput.trimmingCharacters(in: .whitespaces).split(separator: ".").compactMap { Int($0) }
        guard parts.count == 4, parts.allSatisfy({ (0...255).contains($0) }) else {
            errorMessage = "Enter a valid IPv4 address (e.g. 192.168.1.0)."
            return
        }

        let ip: UInt32 = parts.enumerated().reduce(0) { acc, pair in
            acc | (UInt32(pair.element) << (24 - pair.offset * 8))
        }

        let mask: UInt32 = cidr == 0 ? 0 : (0xFFFFFFFF << (32 - cidr))
        let network   = ip & mask
        let broadcast = network | ~mask
        let firstHost = cidr >= 31 ? network    : network + 1
        let lastHost  = cidr >= 31 ? broadcast  : broadcast - 1
        let total     = UInt64(1) << (32 - cidr)
        let usable    = cidr >= 31 ? Int(total) : max(0, Int(total) - 2)

        result = SubnetResult(
            networkAddress:  formatIP(network),
            broadcastAddress: formatIP(broadcast),
            subnetMask:      formatIP(mask),
            firstHost:       formatIP(firstHost),
            lastHost:        formatIP(lastHost),
            usableHosts:     usable,
            totalAddresses:  Int(total),
            prefix:          cidr
        )
    }

    private func formatIP(_ value: UInt32) -> String {
        "\(value >> 24 & 0xFF).\(value >> 16 & 0xFF).\(value >> 8 & 0xFF).\(value & 0xFF)"
    }

    // ── Theme helpers ────────────────────────────────────────────────────

    private var backgroundGradient: some View {
        Group {
            if colorScheme == .dark {
                LinearGradient(
                    colors: [Color(red: 0.03, green: 0.03, blue: 0.08), Color(red: 0.02, green: 0.05, blue: 0.12), .black],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            } else {
                LinearGradient(
                    colors: [Color(red: 0.94, green: 0.96, blue: 0.99), Color(red: 0.88, green: 0.92, blue: 0.97)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            }
        }
    }

    private var cardFill:     Color { colorScheme == .dark ? Color.white.opacity(0.07)  : Color.white.opacity(0.75) }
    private var cardStroke:   Color { colorScheme == .dark ? Color.white.opacity(0.09)  : Color.gray.opacity(0.18) }
    private var inputBackground: Color { colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.05) }
    private var textColor:    Color { colorScheme == .dark ? .white                     : Color(.label) }
    private var subtextColor: Color { colorScheme == .dark ? .white.opacity(0.65)       : Color(.secondaryLabel) }
    private var neonBlue:   Color { Color(red: 0.18, green: 0.78, blue: 1.0) }
    private var neonPurple: Color { Color(red: 0.62, green: 0.34, blue: 1.0) }
}

// ── Data model ────────────────────────────────────────────────────────────

struct SubnetResult {
    let networkAddress: String
    let broadcastAddress: String
    let subnetMask: String
    let firstHost: String
    let lastHost: String
    let usableHosts: Int
    let totalAddresses: Int
    let prefix: Int
}

#Preview { SubnettingView() }
