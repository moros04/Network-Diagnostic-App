import SwiftUI

struct SubnettingView: View {
    @State private var ipInput: String = "192.168.1.0"
    @State private var cidr: Int = 24
    @State private var result: SubnetResult? = nil
    @State private var errorMessage: String? = nil

    private let presets: [(String, Int)] = [("/8", 8), ("/16", 16), ("/24", 24), ("/28", 28), ("/30", 30)]

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        inputCard
                        if let err = errorMessage {
                            errorCard(err)
                        } else if let r = result {
                            utilizationCard(r)
                            resultsCard(r)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Subnet Calc")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Input

    private var inputCard: some View {
        VStack(spacing: 18) {
            // IP Address field
            VStack(alignment: .leading, spacing: 6) {
                Label("IPv4 Address", systemImage: "network")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.5))

                TextField("e.g. 192.168.1.0", text: $ipInput)
                    .keyboardType(.numbersAndPunctuation)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .font(.system(.body, design: .monospaced))
                    .padding(12)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
            }

            // CIDR stepper with presets
            VStack(alignment: .leading, spacing: 10) {
                Label("CIDR Prefix", systemImage: "slash.circle")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.5))

                HStack(spacing: 12) {
                    Button {
                        if cidr > 0 { cidr -= 1 }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white.opacity(0.6))
                    }

                    Text("/\(cidr)")
                        .font(.system(.title2, design: .monospaced).weight(.bold))
                        .foregroundStyle(.white)
                        .frame(minWidth: 64)
                        .multilineTextAlignment(.center)

                    Button {
                        if cidr < 32 { cidr += 1 }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white.opacity(0.6))
                    }

                    Spacer()

                    // Slider area
                    Slider(value: Binding(
                        get: { Double(cidr) },
                        set: { cidr = Int($0) }
                    ), in: 0...32, step: 1)
                    .tint(neonBlue)
                    .frame(maxWidth: .infinity)
                }

                // Preset chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(presets, id: \.1) { label, prefix in
                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    cidr = prefix
                                }
                            } label: {
                                Text(label)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(cidr == prefix ? .black : .white.opacity(0.8))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(cidr == prefix ? neonBlue : Color.white.opacity(0.08))
                                    )
                            }
                        }
                    }
                }
            }

            // Calculate button
            Button(action: calculate) {
                HStack(spacing: 8) {
                    Image(systemName: "equal.circle.fill")
                        .font(.system(size: 16))
                    Text("Calculate")
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [neonPurple, neonBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: neonBlue.opacity(0.28), radius: 14, x: 0, y: 0)
            }
        }
        .padding()
        .background(cardBackground(shadow: neonPurple.opacity(0.10)))
        .padding(.top, 8)
    }

    // MARK: - Utilization Card

    private func utilizationCard(_ r: SubnetResult) -> some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Address Space")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("\(r.usableHosts.formatted()) usable of \(r.totalAddresses.formatted()) total")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
                Text(r.totalAddresses > 0
                     ? String(format: "%.1f%%", Double(r.usableHosts) / Double(r.totalAddresses) * 100)
                     : "—")
                    .font(.system(.callout, design: .rounded).weight(.bold))
                    .foregroundStyle(neonBlue)
            }

            // Stacked bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 10)

                    // Reserved (network + broadcast)
                    let reserved = max(0, r.totalAddresses - r.usableHosts)
                    let reservedFrac = r.totalAddresses > 0 ? CGFloat(reserved) / CGFloat(r.totalAddresses) : 0
                    let usableFrac   = r.totalAddresses > 0 ? CGFloat(r.usableHosts) / CGFloat(r.totalAddresses) : 0

                    HStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(LinearGradient(colors: [neonPurple, neonBlue], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * usableFrac, height: 10)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.orange.opacity(0.6))
                            .frame(width: geo.size.width * reservedFrac, height: 10)
                    }
                }
            }
            .frame(height: 10)

            HStack(spacing: 16) {
                legendDot(color: neonBlue, label: "Usable")
                legendDot(color: .orange, label: "Reserved (Net + BC)")
            }
            .font(.caption2)
            .foregroundStyle(.white.opacity(0.5))
        }
        .padding()
        .background(cardBackground(shadow: neonBlue.opacity(0.10)))
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(label)
        }
    }

    // MARK: - Results

    private func resultsCard(_ r: SubnetResult) -> some View {
        VStack(spacing: 0) {
            resultRow(icon: "network",                title: "Network Address",   value: r.networkAddress,   color: neonBlue,  divider: true)
            resultRow(icon: "dot.radiowaves.right",   title: "Broadcast Address", value: r.broadcastAddress, color: .orange,   divider: true)
            resultRow(icon: "shield.lefthalf.filled", title: "Subnet Mask",       value: r.subnetMask,       color: neonPurple, divider: true)
            resultRow(icon: "arrow.right.circle",     title: "First Usable Host", value: r.firstHost,        color: .green,    divider: true)
            resultRow(icon: "arrow.left.circle",      title: "Last Usable Host",  value: r.lastHost,         color: .green,    divider: true)
            resultRow(icon: "person.3",               title: "Usable Hosts",      value: "\(r.usableHosts.formatted())", color: neonBlue, divider: true)
            resultRow(icon: "square.grid.3x3",        title: "Total Addresses",   value: "\(r.totalAddresses.formatted())", color: neonPurple, divider: true)
            resultRow(icon: "number.circle",          title: "CIDR Notation",     value: "/\(r.prefix)",    color: .cyan,     divider: false)
        }
        .background(cardBackground(shadow: neonBlue.opacity(0.08)))
    }

    private func resultRow(icon: String, title: String, value: String, color: Color, divider: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.14))
                        .frame(width: 38, height: 38)
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(color)
                }

                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.85))

                Spacer()

                Text(value)
                    .font(.system(.subheadline, design: .monospaced).weight(.semibold))
                    .foregroundStyle(.white)
                    .textSelection(.enabled)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)

            if divider {
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 1)
                    .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - Error

    private func errorCard(_ message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.orange.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.orange.opacity(0.25), lineWidth: 1)
                )
        )
    }

    // MARK: - Logic

    private func calculate() {
        errorMessage = nil
        result = nil

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
        let firstHost = cidr >= 31 ? network   : network + 1
        let lastHost  = cidr >= 31 ? broadcast : broadcast - 1
        let total     = UInt64(1) << (32 - cidr)
        let usable    = cidr >= 31 ? Int(total) : max(0, Int(total) - 2)

        withAnimation(.easeOut(duration: 0.25)) {
            result = SubnetResult(
                networkAddress:   formatIP(network),
                broadcastAddress: formatIP(broadcast),
                subnetMask:       formatIP(mask),
                firstHost:        formatIP(firstHost),
                lastHost:         formatIP(lastHost),
                usableHosts:      usable,
                totalAddresses:   Int(total),
                prefix:           cidr
            )
        }
    }

    private func formatIP(_ v: UInt32) -> String {
        "\(v >> 24 & 0xFF).\(v >> 16 & 0xFF).\(v >> 8 & 0xFF).\(v & 0xFF)"
    }

    // MARK: - Style

    private func cardBackground(shadow: Color) -> some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(cardFill)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(cardStroke, lineWidth: 1)
            )
            .shadow(color: shadow, radius: 14, x: 0, y: 0)
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.03, green: 0.03, blue: 0.08),
                Color(red: 0.02, green: 0.05, blue: 0.12),
                Color.black
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var cardFill:   Color { Color.white.opacity(0.07) }
    private var cardStroke: Color { Color.white.opacity(0.09) }
    private var neonBlue:   Color { Color(red: 0.18, green: 0.78, blue: 1.0) }
    private var neonPurple: Color { Color(red: 0.62, green: 0.34, blue: 1.0) }
}

// MARK: - Model

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
