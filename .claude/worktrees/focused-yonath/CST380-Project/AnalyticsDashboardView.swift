//
//  AnalyticsDashboardView.swift
//  CST380-Project
//
//  Historical analytics dashboard — RTT trends, jitter history, and
//  packet loss over time using Swift Charts and stored SwiftData records.
//  Also provides PDF export of all saved diagnostics data.
//

import SwiftUI
import Charts
import SwiftData

struct AnalyticsDashboardView: View {
    @Environment(\.colorScheme)  private var colorScheme
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \LatencyMeasurement.timestamp) private var latencyHistory: [LatencyMeasurement]
    @Query(sort: \DNSLookupResult.timestamp, order: .reverse) private var dnsHistory: [DNSLookupResult]

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        headerCard
                        if latencyHistory.isEmpty {
                            emptyState
                        } else {
                            summaryCard
                            rttChartCard
                            jitterChartCard
                            packetLossChartCard
                        }
                        exportButton
                    }
                    .padding()
                }
            }
            .navigationTitle("Analytics")
            .foregroundStyle(textColor)
        }
    }

    // ── Cards ─────────────────────────────────────────────────────────────

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
                    Image(systemName: "chart.bar.xaxis.ascending.badge.clock")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(neonBlue)
                }
                Text("Analytics Dashboard")
                    .font(.title3.bold())
                    .foregroundStyle(textColor)
                Text("Historical trends from all saved test sessions")
                    .font(.subheadline)
                    .foregroundStyle(subtextColor)
            }
            .padding(.vertical, 28)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 44))
                .foregroundStyle(subtextColor)
            Text("No data yet")
                .font(.headline)
                .foregroundStyle(textColor)
            Text("Run a latency test in the Latency tab to start collecting data.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(subtextColor)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(cardFill)
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(cardStroke, lineWidth: 1))
        )
    }

    private var summaryCard: some View {
        VStack(spacing: 14) {
            Text("All-Time Summary")
                .font(.headline)
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                summaryTile(title: "Sessions",    value: "\(latencyHistory.count)",                      color: neonBlue,   icon: "play.circle")
                summaryTile(title: "Avg RTT",     value: String(format: "%.1f ms", overallAvgRTT),       color: neonPurple, icon: "timer")
                summaryTile(title: "Best RTT",    value: String(format: "%.1f ms", bestRTT),             color: .green,     icon: "arrow.down.circle")
                summaryTile(title: "Worst RTT",   value: String(format: "%.1f ms", worstRTT),            color: .orange,    icon: "arrow.up.circle")
                summaryTile(title: "Avg Jitter",  value: String(format: "%.1f ms", overallAvgJitter),    color: neonBlue,   icon: "waveform.path")
                summaryTile(title: "Avg Loss",    value: String(format: "%.1f%%",  overallAvgPacketLoss), color: .red,       icon: "xmark.circle")
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

    private func summaryTile(title: String, value: String, color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(subtextColor)
            }
            Text(value)
                .font(.system(.title3, design: .rounded).bold())
                .foregroundStyle(textColor)
                .minimumScaleFactor(0.7)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.10))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.2), lineWidth: 1))
        )
    }

    private var rttChartCard: some View {
        chartCard(
            title: "Average RTT Over Time",
            yLabel: "RTT (ms)",
            color: neonBlue
        ) {
            ForEach(Array(latencyHistory.enumerated()), id: \.offset) { idx, m in
                LineMark(
                    x: .value("Session", idx + 1),
                    y: .value("RTT", m.averageRTT)
                )
                .foregroundStyle(neonBlue)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                AreaMark(
                    x: .value("Session", idx + 1),
                    y: .value("RTT", m.averageRTT)
                )
                .foregroundStyle(LinearGradient(
                    colors: [neonBlue.opacity(0.3), .clear],
                    startPoint: .top, endPoint: .bottom
                ))

                PointMark(
                    x: .value("Session", idx + 1),
                    y: .value("RTT", m.averageRTT)
                )
                .foregroundStyle(.white)
                .symbolSize(30)
            }
        }
    }

    private var jitterChartCard: some View {
        chartCard(
            title: "Jitter Over Time",
            yLabel: "Jitter (ms)",
            color: neonPurple
        ) {
            ForEach(Array(latencyHistory.enumerated()), id: \.offset) { idx, m in
                BarMark(
                    x: .value("Session", idx + 1),
                    y: .value("Jitter", m.jitter)
                )
                .foregroundStyle(LinearGradient(
                    colors: [neonPurple, neonBlue.opacity(0.7)],
                    startPoint: .bottom, endPoint: .top
                ))
                .cornerRadius(4)
            }
        }
    }

    private var packetLossChartCard: some View {
        chartCard(
            title: "Packet Loss Over Time",
            yLabel: "Loss (%)",
            color: .orange
        ) {
            ForEach(Array(latencyHistory.enumerated()), id: \.offset) { idx, m in
                BarMark(
                    x: .value("Session", idx + 1),
                    y: .value("Loss", m.packetLoss)
                )
                .foregroundStyle(LinearGradient(
                    colors: [Color.orange, Color.red.opacity(0.7)],
                    startPoint: .bottom, endPoint: .top
                ))
                .cornerRadius(4)
            }
        }
    }

    @ViewBuilder
    private func chartCard<C: ChartContent>(
        title: String,
        yLabel: String,
        color: Color,
        @ChartContentBuilder content: @escaping () -> C
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)
                .foregroundStyle(textColor)
                .padding(.horizontal, 4)

            Chart { content() }
                .frame(height: 180)
                .chartYAxisLabel(yLabel)
                .chartXAxisLabel("Session #")
                .chartXAxis {
                    AxisMarks {
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(axisColor)
                        AxisTick().foregroundStyle(axisColor)
                        AxisValueLabel().foregroundStyle(axisLabelColor)
                    }
                }
                .chartYAxis {
                    AxisMarks {
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(axisColor)
                        AxisTick().foregroundStyle(axisColor)
                        AxisValueLabel().foregroundStyle(axisLabelColor)
                    }
                }
                .padding(.top, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(cardFill)
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(cardStroke, lineWidth: 1))
                .shadow(color: color.opacity(0.10), radius: 14)
        )
    }

    private var exportButton: some View {
        Button {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let root = scene.windows.first?.rootViewController else { return }
            PDFExporter.export(
                latencyHistory: latencyHistory,
                dnsHistory: dnsHistory,
                from: root
            )
        } label: {
            HStack {
                Image(systemName: "arrow.down.doc.fill")
                Text("Export PDF Report")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [neonBlue, neonPurple],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: neonBlue.opacity(0.25), radius: 16)
        }
    }

    // ── Computed stats ─────────────────────────────────────────────────────

    private var overallAvgRTT: Double {
        guard !latencyHistory.isEmpty else { return 0 }
        return latencyHistory.map(\.averageRTT).reduce(0, +) / Double(latencyHistory.count)
    }
    private var overallAvgJitter: Double {
        guard !latencyHistory.isEmpty else { return 0 }
        return latencyHistory.map(\.jitter).reduce(0, +) / Double(latencyHistory.count)
    }
    private var overallAvgPacketLoss: Double {
        guard !latencyHistory.isEmpty else { return 0 }
        return latencyHistory.map(\.packetLoss).reduce(0, +) / Double(latencyHistory.count)
    }
    private var bestRTT: Double  { latencyHistory.map(\.averageRTT).min() ?? 0 }
    private var worstRTT: Double { latencyHistory.map(\.averageRTT).max() ?? 0 }

    // ── Theme helpers ──────────────────────────────────────────────────────

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

    private var cardFill:      Color { colorScheme == .dark ? Color.white.opacity(0.07) : Color.white.opacity(0.75) }
    private var cardStroke:    Color { colorScheme == .dark ? Color.white.opacity(0.09) : Color.gray.opacity(0.18) }
    private var textColor:     Color { colorScheme == .dark ? .white                    : Color(.label) }
    private var subtextColor:  Color { colorScheme == .dark ? .white.opacity(0.65)      : Color(.secondaryLabel) }
    private var axisColor:     Color { colorScheme == .dark ? .white.opacity(0.12)      : Color.gray.opacity(0.3) }
    private var axisLabelColor: Color { colorScheme == .dark ? .white.opacity(0.7)      : Color(.secondaryLabel) }
    private var neonBlue:   Color { Color(red: 0.18, green: 0.78, blue: 1.0) }
    private var neonPurple: Color { Color(red: 0.62, green: 0.34, blue: 1.0) }
}

#Preview { AnalyticsDashboardView() }
