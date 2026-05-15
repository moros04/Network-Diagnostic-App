//
//  DNSLookupView.swift
//  CST380-Project
//
//  Resolves a domain to its A and AAAA records using getaddrinfo
//  and displays the results alongside a history of past lookups.
//

import SwiftUI
import SwiftData

struct DNSLookupView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext

    @State private var manager = DNSLookupManager()
    @State private var domainInput: String = ""
    @Query(sort: \DNSLookupResult.timestamp, order: .reverse) private var history: [DNSLookupResult]

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        headerCard
                        searchCard
                        if manager.isLooking {
                            loadingCard
                        } else if let err = manager.errorMessage {
                            errorCard(err)
                        } else if !manager.ipv4Addresses.isEmpty || !manager.ipv6Addresses.isEmpty {
                            resultsCard
                        }
                        if !history.isEmpty {
                            historyCard
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("DNS Lookup")
            .foregroundStyle(textColor)
            .onAppear { manager.modelContext = modelContext }
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
                        .fill(neonPurple.opacity(0.15))
                        .frame(width: 74, height: 74)
                    Image(systemName: "globe.americas.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(neonPurple)
                }
                Text("DNS Lookup Tool")
                    .font(.title3.bold())
                    .foregroundStyle(textColor)
                Text("Resolve domains to IPv4 and IPv6 addresses and measure resolution time")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(subtextColor)
            }
            .padding(.vertical, 28)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
    }

    private var searchCard: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Label("Domain Name", systemImage: "magnifyingglass")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(subtextColor)

                HStack(spacing: 10) {
                    TextField("e.g. google.com", text: $domainInput)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding(12)
                        .background(inputBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(textColor)
                        .onSubmit { startLookup() }

                    Button(action: startLookup) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(
                                LinearGradient(colors: [neonPurple, neonBlue], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                    }
                    .disabled(domainInput.trimmingCharacters(in: .whitespaces).isEmpty || manager.isLooking)
                }
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

    private var loadingCard: some View {
        HStack(spacing: 14) {
            ProgressView()
                .tint(neonBlue)
            Text("Resolving \(domainInput)…")
                .font(.subheadline)
                .foregroundStyle(subtextColor)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(cardFill)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(cardStroke, lineWidth: 1))
        )
    }

    private var resultsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(domainInput)
                    .font(.headline)
                    .foregroundStyle(textColor)
                Spacer()
                Label(String(format: "%.1f ms", manager.resolutionTime), systemImage: "clock")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(neonBlue)
            }

            if !manager.ipv4Addresses.isEmpty {
                recordGroup(label: "A Records (IPv4)", icon: "4.circle.fill", color: neonBlue, addresses: manager.ipv4Addresses)
            }
            if !manager.ipv6Addresses.isEmpty {
                recordGroup(label: "AAAA Records (IPv6)", icon: "6.circle.fill", color: neonPurple, addresses: manager.ipv6Addresses)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(cardFill)
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(cardStroke, lineWidth: 1))
                .shadow(color: neonBlue.opacity(0.10), radius: 14)
        )
    }

    private func recordGroup(label: String, icon: String, color: Color, addresses: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)

            ForEach(addresses, id: \.self) { addr in
                HStack {
                    Text(addr)
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundStyle(textColor)
                    Spacer()
                    Button {
                        UIPasteboard.general.string = addr
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                            .foregroundStyle(subtextColor)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.08))
                )
            }
        }
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

    private var historyCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("History")
                    .font(.headline)
                    .foregroundStyle(textColor)
                Spacer()
                Button("Clear", role: .destructive) {
                    history.forEach { modelContext.delete($0) }
                    try? modelContext.save()
                }
                .font(.subheadline)
            }

            VStack(spacing: 10) {
                ForEach(history.prefix(10)) { record in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(record.domain)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(textColor)
                            Spacer()
                            Text(String(format: "%.1f ms", record.resolutionTime))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(neonBlue)
                        }
                        Text(record.timestamp.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(subtextColor)

                        if !record.ipv4Addresses.isEmpty {
                            Text(record.ipv4Addresses.prefix(2).joined(separator: ", "))
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(neonBlue.opacity(0.8))
                        }
                        if !record.ipv6Addresses.isEmpty {
                            Text(record.ipv6Addresses.first ?? "")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(neonPurple.opacity(0.8))
                                .lineLimit(1)
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.03))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(cardStroke, lineWidth: 1))
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(cardFill)
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(cardStroke, lineWidth: 1))
                .shadow(color: neonBlue.opacity(0.10), radius: 14)
        )
    }

    // ── Actions ───────────────────────────────────────────────────────────

    private func startLookup() {
        let domain = domainInput.trimmingCharacters(in: .whitespaces)
        guard !domain.isEmpty else { return }
        manager.lookup(domain: domain)
    }

    // ── Theme helpers ─────────────────────────────────────────────────────

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

    private var cardFill:       Color { colorScheme == .dark ? Color.white.opacity(0.07)  : Color.white.opacity(0.75) }
    private var cardStroke:     Color { colorScheme == .dark ? Color.white.opacity(0.09)  : Color.gray.opacity(0.18) }
    private var inputBackground: Color { colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.05) }
    private var textColor:      Color { colorScheme == .dark ? .white                     : Color(.label) }
    private var subtextColor:   Color { colorScheme == .dark ? .white.opacity(0.65)       : Color(.secondaryLabel) }
    private var neonBlue:   Color { Color(red: 0.18, green: 0.78, blue: 1.0) }
    private var neonPurple: Color { Color(red: 0.62, green: 0.34, blue: 1.0) }
}

#Preview { DNSLookupView() }
