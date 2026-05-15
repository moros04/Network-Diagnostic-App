import SwiftUI

struct ConnectivityView: View {
    @State private var monitor = NetworkMonitor()
    @State private var selectedInfo: String? = nil

    private let infoText: [String: String] = [
        "Status":      "Shows whether your device currently has an active internet connection.",
        "Interface":   "The network interface in use — Wi-Fi, Cellular, Ethernet, or Unknown.",
        "IPv4":        "IPv4 uses 32-bit addresses (e.g. 192.168.1.1). Most networks still rely on it.",
        "IPv6":        "IPv6 uses 128-bit addresses designed to replace IPv4 with a vastly larger address space.",
        "Expensive":   "Cellular data is marked 'expensive' because it can cost money or drain battery faster.",
        "Constrained": "When Low Data Mode is enabled, apps are asked to reduce background data usage."
    ]

    private let infoIcons: [String: String] = [
        "Status":      "dot.radiowaves.left.and.right",
        "Interface":   "wifi",
        "IPv4":        "network",
        "IPv6":        "globe",
        "Expensive":   "dollarsign.circle",
        "Constrained": "gauge.with.needle"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        statusHero
                        metricsGrid
                        connectionDetailCard
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Network")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: Binding(
            get: { selectedInfo != nil },
            set: { if !$0 { selectedInfo = nil } }
        )) {
            if let item = selectedInfo { infoSheet(for: item) }
        }
    }

    // MARK: - Hero

    private var statusHero: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32)
                .fill(cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(statusColor.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: statusColor.opacity(0.18), radius: 28, x: 0, y: 0)

            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .stroke(statusColor.opacity(0.08), lineWidth: 18)
                        .frame(width: 124, height: 124)

                    Circle()
                        .stroke(statusColor.opacity(0.20), lineWidth: 2)
                        .frame(width: 107, height: 107)

                    Circle()
                        .fill(statusColor.opacity(0.10))
                        .frame(width: 92, height: 92)

                    Image(systemName: interfaceIcon)
                        .font(.system(size: 34, weight: .medium))
                        .foregroundStyle(statusColor)
                        .contentTransition(.symbolEffect(.replace))
                }

                VStack(spacing: 6) {
                    Text(monitor.isConnected ? "Connected" : "No Connection")
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    HStack(spacing: 6) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 7, height: 7)
                        Text(monitor.isConnected ? monitor.interfaceType : "Offline")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.65))
                    }
                }
            }
            .padding(.vertical, 36)
        }
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.35), value: monitor.isConnected)
        .padding(.top, 8)
    }

    // MARK: - 2×2 Metric Grid

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            metricTile(
                key: "IPv4",
                icon: "network",
                label: "IPv4",
                value: monitor.isIPv4Available ? "Available" : "Unavailable",
                color: monitor.isIPv4Available ? .green : .gray
            )
            metricTile(
                key: "IPv6",
                icon: "globe",
                label: "IPv6",
                value: monitor.isIPv6Available ? "Available" : "Unavailable",
                color: monitor.isIPv6Available ? neonBlue : .gray
            )
            metricTile(
                key: "Expensive",
                icon: "dollarsign.circle",
                label: "Metered",
                value: monitor.isExpensive ? "Yes" : "No",
                color: monitor.isExpensive ? .orange : .green
            )
            metricTile(
                key: "Constrained",
                icon: "gauge.with.needle",
                label: "Low Data",
                value: monitor.isConstrained ? "Active" : "Off",
                color: monitor.isConstrained ? neonPurple : .green
            )
        }
    }

    private func metricTile(key: String, icon: String, label: String, value: String, color: Color) -> some View {
        Button { selectedInfo = key } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.14))
                            .frame(width: 32, height: 32)
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(color)
                    }
                    Spacer()
                    Image(systemName: "info.circle")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.25))
                }

                Spacer()

                Text(value)
                    .font(.system(.callout, design: .rounded).weight(.bold))
                    .foregroundStyle(color)
                    .minimumScaleFactor(0.8)

                Text(label)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(cardFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(color.opacity(0.18), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Connection Detail Card

    private var connectionDetailCard: some View {
        VStack(spacing: 0) {
            detailRow(
                key: "Status",
                icon: "dot.radiowaves.left.and.right",
                label: "Connection Status",
                value: monitor.isConnected ? "Connected" : "Disconnected",
                color: monitor.isConnected ? .green : .red,
                showDivider: true
            )
            detailRow(
                key: "Interface",
                icon: interfaceIcon,
                label: "Interface Type",
                value: monitor.interfaceType,
                color: neonBlue,
                showDivider: false
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(cardStroke, lineWidth: 1)
                )
        )
    }

    private func detailRow(key: String, icon: String, label: String, value: String, color: Color, showDivider: Bool) -> some View {
        Button { selectedInfo = key } label: {
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.14))
                            .frame(width: 40, height: 40)
                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(color)
                    }

                    Text(label)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)

                    Spacer()

                    Text(value)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(color)

                    Image(systemName: "chevron.right")
                        .font(.caption2.bold())
                        .foregroundStyle(.white.opacity(0.22))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 15)

                if showDivider {
                    Rectangle()
                        .fill(Color.white.opacity(0.07))
                        .frame(height: 1)
                        .padding(.horizontal, 16)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Info Sheet

    private func infoSheet(for item: String) -> some View {
        ZStack {
            Color(red: 0.04, green: 0.04, blue: 0.10).ignoresSafeArea()

            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .fill(neonBlue.opacity(0.12))
                        .frame(width: 76, height: 76)
                    Image(systemName: infoIcons[item] ?? "info.circle.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(neonBlue)
                }

                VStack(spacing: 10) {
                    Text(item)
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    Text(infoText[item] ?? "No information available.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.72))
                        .padding(.horizontal, 8)
                }

                Button { selectedInfo = nil } label: {
                    Text("Done")
                        .fontWeight(.semibold)
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
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.top, 6)
            }
            .padding(28)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(32)
    }

    // MARK: - Helpers

    private var interfaceIcon: String {
        switch monitor.interfaceType {
        case "Wi-Fi":    return "wifi"
        case "Cellular": return "antenna.radiowaves.left.and.right"
        case "Ethernet": return "cable.connector"
        default:         return "wifi.slash"
        }
    }

    private var statusColor: Color {
        monitor.isConnected ? .green : .red
    }

    // MARK: - Style

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
