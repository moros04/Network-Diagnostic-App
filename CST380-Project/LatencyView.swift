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
                backgroundGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        headerCard
                        chartCard
                        if latencyMonitor.isRunning {
                            progressCard
                        }
                        statsCard
                        startStopButton
                        if !history.isEmpty {
                            historyCard
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Latency Analyzer")
            .foregroundStyle(.white)
            .shadow(color: .blue.opacity(0.9), radius: 6)
            .onAppear {
                latencyMonitor.modelContext = modelContext
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
                        .fill(neonPurple.opacity(0.15))
                        .frame(width: 74, height: 74)

                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(neonBlue)
                }

                Text("Live Latency Analyzer")
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                Text("Monitor RTT, jitter, and packet loss in real time")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.65))
            }
            .padding(.vertical, 28)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Live RTT Chart")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 4)

            Chart {
                let points = Array(latencyMonitor.measurements.enumerated()).map { (idx, rtt) in
                    (x: idx + 1, y: rtt)
                }
                ForEach(points, id: \.x) { point in
                    AreaMark(
                        x: .value("Ping", point.x),
                        y: .value("RTT", point.y)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [neonBlue.opacity(0.30), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    LineMark(
                        x: .value("Ping", point.x),
                        y: .value("RTT", point.y)
                    )
                    .foregroundStyle(neonBlue)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                    PointMark(
                        x: .value("Ping", point.x),
                        y: .value("RTT", point.y)
                    )
                    .foregroundStyle(.white)
                }
            }
            .frame(height: 220)
            .chartYAxisLabel("RTT (ms)")
            .chartXAxisLabel("Ping #")
            .chartXAxis {
                AxisMarks() { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(.white.opacity(0.12))
                    AxisTick()
                        .foregroundStyle(.white.opacity(0.35))
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .chartYAxis {
                AxisMarks() { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(.white.opacity(0.12))
                    AxisTick()
                        .foregroundStyle(.white.opacity(0.35))
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(cardStroke, lineWidth: 1)
                )
                .shadow(color: neonBlue.opacity(0.12), radius: 16, x: 0, y: 0)
        )
    }

    private var progressCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Test Progress")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text("\(Int(latencyMonitor.progress * 100))%")
                    .font(.subheadline.bold())
                    .foregroundStyle(neonBlue)
            }
            ProgressView(value: latencyMonitor.progress)
                .tint(neonBlue)
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
            Text("Running test…")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(cardStroke, lineWidth: 1)
                )
                .shadow(color: neonPurple.opacity(0.10), radius: 14, x: 0, y: 0)
        )
    }

    private var statsCard: some View {
        VStack(spacing: 14) {
            metricRow(
                icon: "timer",
                title: "Average RTT",
                value: String(format: "%.2f ms", latencyMonitor.averageRTT),
                color: neonBlue
            )
            metricRow(
                icon: "waveform.path",
                title: "Jitter",
                value: String(format: "%.2f ms", latencyMonitor.jitter),
                color: neonPurple
            )
            metricRow(
                icon: "chart.line.uptrend.xyaxis",
                title: "p95 RTT",
                value: String(format: "%.2f ms", latencyMonitor.p95RTT),
                color: .green
            )
            metricRow(
                icon: "exclamationmark.triangle",
                title: "Packet Loss",
                value: String(format: "%.2f%%", latencyMonitor.packetLoss),
                color: .orange
            )
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

    private var startStopButton: some View {
        Button {
            if latencyMonitor.isRunning {
                latencyMonitor.stopMeasuring()
            } else {
                latencyMonitor.measurements = []
                latencyMonitor.averageRTT = 0
                latencyMonitor.jitter = 0
                latencyMonitor.p95RTT = 0
                latencyMonitor.packetLoss = 0
                latencyMonitor.startMeasuring()
            }
        } label: {
            HStack {
                Image(systemName: latencyMonitor.isRunning ? "stop.fill" : "play.fill")
                Text(latencyMonitor.isRunning ? "Stop Test" : "Start Test")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: latencyMonitor.isRunning
                        ? [Color.red.opacity(0.9), Color.orange.opacity(0.85)]
                        : [neonPurple, neonBlue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(
                color: latencyMonitor.isRunning
                    ? Color.red.opacity(0.25)
                    : neonBlue.opacity(0.25),
                radius: 16,
                x: 0,
                y: 0
            )
        }
    }

    private var historyCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("History")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.9))

                Spacer()

                Button("Reset", role: .destructive) {
                    for item in history {
                        modelContext.delete(item)
                    }
                    try? modelContext.save()
                }
            }

            VStack(spacing: 12) {
                ForEach(history) { measurement in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(measurement.timestamp.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.55))

                        historyMetricRow(title: "Avg RTT", value: String(format: "%.2f ms", measurement.averageRTT))
                        historyMetricRow(title: "p95 RTT", value: String(format: "%.2f ms", measurement.p95RTT))
                        historyMetricRow(title: "Jitter", value: String(format: "%.2f ms", measurement.jitter))
                        historyMetricRow(title: "Loss", value: String(format: "%.2f%%", measurement.packetLoss))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                            )
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(cardStroke, lineWidth: 1)
                )
                .shadow(color: neonBlue.opacity(0.10), radius: 14, x: 0, y: 0)
        )
    }

    private func metricRow(icon: String, title: String, value: String, color: Color) -> some View {
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
                .foregroundStyle(.white)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.82))
        }
        .padding(.vertical, 6)
    }

    private func historyMetricRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.white.opacity(0.75))

            Spacer()

            Text(value)
                .foregroundStyle(.white)
        }
        .font(.subheadline)
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
    
#Preview{
    LatencyView()
}
