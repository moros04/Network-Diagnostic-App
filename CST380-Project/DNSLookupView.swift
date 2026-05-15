import SwiftUI
import SwiftData

struct DNSLookupView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var manager = DNSLookupManager()
    @State private var domainInput: String = ""
    @Query(sort: \DNSLookupResult.timestamp, order: .reverse) private var history: [DNSLookupResult]

    private let quickDomains = ["google.com", "cloudflare.com", "apple.com", "github.com"]

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        searchCard
                        quickLookupRow
                        if manager.isLooking {
                            loadingCard
                        } else if let err = manager.errorMessage {
                            errorCard(err)
                        } else if !manager.ipv4Addresses.isEmpty || !manager.ipv6Addresses.isEmpty {
                            resultsCard
                        }
                        if !history.isEmpty { historyCard }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("DNS Lookup")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { manager.modelContext = modelContext }
        }
    }

    // MARK: - Search

    private var searchCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Domain Name", systemImage: "magnifyingglass")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.5))

            HStack(spacing: 10) {
                TextField("e.g. google.com", text: $domainInput)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .font(.system(.body, design: .monospaced))
                    .padding(12)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
                    .onSubmit { startLookup() }

                Button(action: startLookup) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [neonPurple, neonBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .disabled(domainInput.trimmingCharacters(in: .whitespaces).isEmpty || manager.isLooking)
                .opacity(domainInput.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1.0)
            }
        }
        .padding()
        .background(cardBackground(shadow: neonPurple.opacity(0.10)))
        .padding(.top, 8)
    }

    // MARK: - Quick Lookup Chips

    private var quickLookupRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(quickDomains, id: \.self) { domain in
                    Button {
                        domainInput = domain
                        startLookup()
                    } label: {
                        Text(domain)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.85))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.08))
                                    .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
                            )
                    }
                    .disabled(manager.isLooking)
                }
            }
            .padding(.horizontal, 1)
        }
        .padding(.horizontal, -4)
    }

    // MARK: - Loading

    private var loadingCard: some View {
        HStack(spacing: 14) {
            ProgressView()
                .tint(neonBlue)
            VStack(alignment: .leading, spacing: 2) {
                Text("Resolving...")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(domainInput)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.55))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground(shadow: neonBlue.opacity(0.08)))
    }

    // MARK: - Results

    private var resultsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(domainInput)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Resolution complete")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.45))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text(String(format: "%.1f ms", manager.resolutionTime))
                        .font(.system(.callout, design: .rounded).weight(.bold))
                        .foregroundStyle(resolutionTimeColor)
                    Label("RTT", systemImage: "clock")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.4))
                }
            }

            if !manager.ipv4Addresses.isEmpty {
                addressGroup(
                    label: "A Records (IPv4)",
                    icon: "4.circle.fill",
                    color: neonBlue,
                    addresses: manager.ipv4Addresses
                )
            }
            if !manager.ipv6Addresses.isEmpty {
                addressGroup(
                    label: "AAAA Records (IPv6)",
                    icon: "6.circle.fill",
                    color: neonPurple,
                    addresses: manager.ipv6Addresses
                )
            }
        }
        .padding()
        .background(cardBackground(shadow: neonBlue.opacity(0.10)))
    }

    private func addressGroup(label: String, icon: String, color: Color, addresses: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)

            VStack(spacing: 6) {
                ForEach(addresses, id: \.self) { addr in
                    HStack {
                        Text(addr)
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.9))
                            .textSelection(.enabled)
                        Spacer()
                        Button {
                            UIPasteboard.general.string = addr
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 13))
                                .foregroundStyle(color.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(color.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(color.opacity(0.14), lineWidth: 1)
                            )
                    )
                }
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

    // MARK: - History

    private var historyCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Recent Lookups")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Button(role: .destructive) {
                    history.forEach { modelContext.delete($0) }
                    try? modelContext.save()
                } label: {
                    Label("Clear", systemImage: "trash")
                        .font(.subheadline)
                        .foregroundStyle(.red.opacity(0.8))
                }
            }

            VStack(spacing: 8) {
                ForEach(history.prefix(10)) { record in
                    Button {
                        domainInput = record.domain
                        startLookup()
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(neonBlue.opacity(0.12))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "globe")
                                    .font(.system(size: 14))
                                    .foregroundStyle(neonBlue)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text(record.domain)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white)
                                Text(record.timestamp.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.4))
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 3) {
                                Text(String(format: "%.0fms", record.resolutionTime))
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(neonBlue)
                                if !record.ipv4Addresses.isEmpty {
                                    Text(record.ipv4Addresses.first ?? "")
                                        .font(.system(.caption2, design: .monospaced))
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.07), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(cardBackground(shadow: neonBlue.opacity(0.08)))
    }

    // MARK: - Actions

    private func startLookup() {
        let domain = domainInput.trimmingCharacters(in: .whitespaces)
        guard !domain.isEmpty else { return }
        manager.lookup(domain: domain)
    }

    // MARK: - Helpers

    private var resolutionTimeColor: Color {
        switch manager.resolutionTime {
        case ..<30:  return .green
        case ..<100: return neonBlue
        case ..<300: return .orange
        default:     return .red
        }
    }

    private func cardBackground(shadow: Color) -> some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(cardFill)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(cardStroke, lineWidth: 1)
            )
            .shadow(color: shadow, radius: 14, x: 0, y: 0)
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

#Preview { DNSLookupView() }
