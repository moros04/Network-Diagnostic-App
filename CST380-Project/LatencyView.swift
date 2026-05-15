import SwiftUI
import Charts
import SwiftData

struct LatencyView: View {
    @State private var latencyMonitor = LatencyMonitor()
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LatencyMeasurement.timestamp, order: .reverse) private var history: [LatencyMeasurement]

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        statsGrid
                        chartCard
                        if latencyMonitor.isRunning { progressCard }
                        startStopButton
                        if !history.isEmpty { historyCard }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Latency")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { latencyMonitor.modelContext = modelContext }
        }
    }

    // MARK: - 2×2 Stats Grid

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statTile(icon: "timer", title: "Avg RTT",
                     value: formatted(latencyMonitor.averageRTT), unit: "ms", color: neonBlue)
            statTile(icon: "waveform.path", title: "Jitter",
                     value: formatted(latencyMonitor.jitter), unit: "ms", color: neonPurple)
            statTile(icon: "chart.line.uptrend.xyaxis", title: "p95 RTT",
                     value: formatted(latencyMonitor.p95RTT), unit: "ms", color: .green)
            statTile(icon: "exclamationmark.triangle", title: "Packet Loss",
                     value: String(format: "%.1f", latencyMonitor.packetLoss), unit: "%", color: .orange)
        }
        .padding(.top, 8)
    }

    private func statTile(icon: String, title: String, value: String, unit: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.14))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
            }

            Spacer()

            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.7)
                Text(unit)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.55))
            }

            Text(title)
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

    // MARK: - Chart

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("RTT Over Time")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                if latencyMonitor.isRunning {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(.green)
                            .frame(width: 6, height: 6)
                        Text("Live")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.green)
                    }
                }
            }

            if latencyMonitor.measurements.isEmpty {
                chartEmptyState
            } else {
                Chart {
                    let points = latencyMonitor.measurements.enumerated().map { (idx, rtt) in (x: idx + 1, y: rtt) }
                    ForEach(points, id: \.x) { point in
                        AreaMark(
                            x: .value("Ping", point.x),
                            y: .value("RTT", point.y)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [neonBlue.opacity(0.28), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        LineMark(
                            x: .value("Ping", point.x),
                            y: .value("RTT", point.y)
                        )
                        .foregroundStyle(neonBlue)
                        .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                        PointMark(
                            x: .value("Ping", point.x),
                            y: .value("RTT", point.y)
                        )
                        .symbolSize(28)
                        .foregroundStyle(.white)
                    }
                }
                .frame(height: 200)
                .chartYAxisLabel("ms")
                .chartXAxisLabel("Ping #")
                .chartXAxis {
                    AxisMarks {
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(.white.opacity(0.10))
                        AxisValueLabel().foregroundStyle(.white.opacity(0.65))
                    }
                }
                .chartYAxis {
                    AxisMarks {
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(.white.opacity(0.10))
                        AxisValueLabel().foregroundStyle(.white.opacity(0.65))
                    }
                }
            }
        }
        .padding()
        .background(cardBackground(shadow: neonBlue.opacity(0.10)))
    }

    private var chartEmptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 32))
                .foregroundStyle(.white.opacity(0.2))
            Text("Start a test to see live RTT data")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
    }

    // MARK: - Progress

    private var progressCard: some View {
        VStack(spacing: 12) {
            HStack {
                Label("Running Test", systemImage: "dot.radiowaves.left.and.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(Int(latencyMonitor.progress * 100))%")
                    .font(.subheadline.bold())
                    .foregroundStyle(neonBlue)
            }
            ProgressView(value: latencyMonitor.progress)
                .tint(neonBlue)
                .scaleEffect(x: 1, y: 1.4, anchor: .center)
        }
        .padding()
        .background(cardBackground(shadow: neonPurple.opacity(0.10)))
    }

    // MARK: - Start/Stop

    private var startStopButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if latencyMonitor.isRunning {
                    latencyMonitor.stopMeasuring()
                } else {
                    latencyMonitor.measurements = []
                    latencyMonitor.averageRTT  = 0
                    latencyMonitor.jitter      = 0
                    latencyMonitor.p95RTT      = 0
                    latencyMonitor.packetLoss  = 0
                    latencyMonitor.startMeasuring()
                }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: latencyMonitor.isRunning ? "stop.fill" : "play.fill")
                    .font(.system(size: 15, weight: .bold))
                Text(latencyMonitor.isRunning ? "Stop Test" : "Start Test")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Group {
                    if latencyMonitor.isRunning {
                        LinearGradient(colors: [Color.red.opacity(0.9), Color.orange.opacity(0.85)],
                                       startPoint: .leading, endPoint: .trailing)
                    } else {
                        LinearGradient(colors: [neonPurple, neonBlue],
                                       startPoint: .leading, endPoint: .trailing)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(
                color: latencyMonitor.isRunning ? Color.red.opacity(0.3) : neonBlue.opacity(0.3),
                radius: 14, x: 0, y: 0
            )
        }
    }

    // MARK: - History

    private var historyCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("History")
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

            // Column headers
            HStack {
                Text("Date")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Avg")
                    .frame(width: 60, alignment: .trailing)
                Text("Jitter")
                    .frame(width: 55, alignment: .trailing)
                Text("Loss")
                    .frame(width: 45, alignment: .trailing)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white.opacity(0.4))
            .padding(.horizontal, 4)

            VStack(spacing: 8) {
                ForEach(history) { m in
                    historyRow(m)
                }
            }
        }
        .padding()
        .background(cardBackground(shadow: neonBlue.opacity(0.08)))
    }

    private func historyRow(_ m: LatencyMeasurement) -> some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(m.timestamp.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.85))
                Text(m.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.4))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(String(format: "%.1fms", m.averageRTT))
                .font(.system(.caption, design: .monospaced).weight(.semibold))
                .foregroundStyle(rttColor(m.averageRTT))
                .frame(width: 60, alignment: .trailing)

            Text(String(format: "%.1fms", m.jitter))
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.white.opacity(0.65))
                .frame(width: 55, alignment: .trailing)

            Text(String(format: "%.0f%%", m.packetLoss))
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(m.packetLoss > 0 ? .orange : .green)
                .frame(width: 45, alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }

    // MARK: - Helpers

    private func formatted(_ value: Double) -> String {
        String(format: "%.1f", value)
    }

    private func rttColor(_ rtt: Double) -> Color {
        switch rtt {
        case ..<50:  return .green
        case ..<150: return neonBlue
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

#Preview {
    LatencyView()
}
