//
//  ContentView.swift
//  CST380-Project
//
//  Created by Miguel O on 3/12/26.
//

import SwiftUI

struct ConnectivityView: View {
    @State private var monitor = NetworkMonitor()
    @State private var selectedInfo: String? = nil

    let infoText: [String: String] = [
        "Status": "Shows whether your device currently has an active internet connection.",
        "Interface": "Indicates the network interface being used, such as Wi-Fi or Cellular.",
        "IPv4": "IPv4 is the older internet addressing system. Many networks still rely on it.",
        "IPv6": "IPv6 is the newer addressing system designed to replace IPv4.",
        "Expensive": "An expensive connection is one that may result in charges, such as cellular data.",
        "Constrained": "A constrained connection limits data usage, often due to Low Data Mode."
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        headerCard
                        infoCard(title: "Connection") {
                            statusButton(
                                key: "Status",
                                icon: "dot.radiowaves.left.and.right",
                                label: "Status",
                                value: monitor.isConnected ? "Connected" : "Disconnected",
                                color: monitor.isConnected ? .green : .red
                            )

                            statusButton(
                                key: "Interface",
                                icon: "wifi",
                                label: "Interface",
                                value: monitor.interfaceType,
                                color: neonBlue
                            )
                        }

                        infoCard(title: "IP Support") {
                            statusButton(
                                key: "IPv4",
                                icon: "network",
                                label: "IPv4",
                                value: monitor.isIPv4Available ? "Available" : "Unavailable",
                                color: monitor.isIPv4Available ? .green : .gray
                            )

                            statusButton(
                                key: "IPv6",
                                icon: "globe",
                                label: "IPv6",
                                value: monitor.isIPv6Available ? "Available" : "Unavailable",
                                color: monitor.isIPv6Available ? .green : .gray
                            )
                        }

                        infoCard(title: "Details") {
                            statusButton(
                                key: "Expensive",
                                icon: "dollarsign.circle",
                                label: "Expensive",
                                value: monitor.isExpensive ? "Yes" : "No",
                                color: monitor.isExpensive ? neonPurple : .green
                            )

                            statusButton(
                                key: "Constrained",
                                icon: "speedometer",
                                label: "Constrained",
                                value: monitor.isConstrained ? "Yes" : "No",
                                color: monitor.isConstrained ? neonPurple : .green
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Network Monitor")
            .foregroundStyle(.white)
            .shadow(color: .blue.opacity(0.9), radius: 6)
        }
        .sheet(isPresented: Binding(
            get: { selectedInfo != nil },
            set: { if !$0 { selectedInfo = nil } }
        )) {
            if let item = selectedInfo {
                ZStack {
                    Color.black.ignoresSafeArea()

                    VStack(spacing: 18) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 34))
                            .foregroundStyle(neonBlue)

                        Text(item)
                            .font(.title2.bold())
                            .foregroundStyle(.white)

                        Text(infoText[item] ?? "No information available.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.horizontal)

                        Button {
                            selectedInfo = nil
                        } label: {
                            Text("Close")
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
                        .padding(.top, 8)
                    }
                    .padding(24)
                }
                .presentationDetents([.medium])
            }
        }
    }

    private var headerCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(cardStroke, lineWidth: 1)
                )
                .shadow(color: neonBlue.opacity(0.18), radius: 20, x: 0, y: 0)

            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(neonBlue.opacity(0.15))
                        .frame(width: 74, height: 74)

                    Image(systemName: monitor.isConnected ? "wifi" : "wifi.slash")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(monitor.isConnected ? .green : .red)
                }

                Text(monitor.isConnected ? "Network Connected" : "No Active Connection")
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                Text("Live device connectivity diagnostics")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.65))
            }
            .padding(.vertical, 28)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
    }

    private func infoCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 4)

            VStack(spacing: 14) {
                content()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(cardFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(cardStroke, lineWidth: 1)
                    )
                    .shadow(color: neonPurple.opacity(0.12), radius: 16, x: 0, y: 0)
            )
        }
    }

    private func statusButton(
        key: String,
        icon: String,
        label: String,
        value: String,
        color: Color
    ) -> some View {
        Button {
            selectedInfo = key
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.18))
                        .frame(width: 42, height: 42)

                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)

                    Text("Tap for details")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.45))
                }

                Spacer()

                HStack(spacing: 8) {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)

                    Text(value)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.82))
                }

                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.28))
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }

    private var backgroundGradient: some View {
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

    private var cardFill: Color {
        Color.white.opacity(0.07)
    }

    private var cardStroke: Color {
        Color.white.opacity(0.09)
    }

    private var neonBlue: Color {
        Color(red: 0.18, green: 0.78, blue: 1.0)
    }

    private var neonPurple: Color {
        Color(red: 0.62, green: 0.34, blue: 1.0)
    }
}
