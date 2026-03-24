import SwiftUI
import Charts
import SwiftData

struct LatencyView: View{
    @State private var latencyMonitor = LatencyMonitor()
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LatencyMeasurement.timestamp, order: .reverse) private var history: [LatencyMeasurement]
    
    var body: some View{
        NavigationView{
            VStack(spacing: 20){
                Chart {
                    let points = Array(latencyMonitor.measurements.enumerated()).map { (idx, rtt) in
                        (x: idx + 1, y: rtt)
                    }
                    ForEach(points, id: \.x) { point in
                        LineMark(
                            x: .value("Ping", point.x),
                            y: .value("RTT", point.y)
                        )
                        .foregroundStyle(.blue)
                        PointMark(
                            x: .value("Ping", point.x),
                            y: .value("RTT", point.y)
                        )
                    }
                }
                .frame(height: 200)
                .padding()
                .chartYAxisLabel("RTT (ms)")
                .chartXAxisLabel("Ping #")
                
                Divider()
//                    .padding(.horizonta)
                HStack { Text("Avg RTT"); Spacer(); Text(String(format: "%.2f ms", latencyMonitor.averageRTT)) }
                    .padding(.horizontal, 15)
                HStack { Text("Jitter"); Spacer(); Text(String(format: "%.2f ms", latencyMonitor.jitter)) }
                    .padding(.horizontal, 15)
                HStack { Text("p95 RTT"); Spacer(); Text(String(format: "%.2f ms", latencyMonitor.p95RTT)) }
                    .padding(.horizontal, 15)
                HStack { Text("Packet Loss"); Spacer(); Text(String(format: "%.2f%%", latencyMonitor.packetLoss)) }
                    .padding(.horizontal, 15)
                
                Button(action: {
                    if latencyMonitor.isRunning{
                        latencyMonitor.stopMeasuring()
                    } else {
                        latencyMonitor.measurements = []
                        latencyMonitor.averageRTT = 0
                        latencyMonitor.jitter = 0
                        latencyMonitor.p95RTT = 0
                        latencyMonitor.packetLoss = 0
                        latencyMonitor.startMeasuring()
                    }
                }){
                    Text(latencyMonitor.isRunning ? "Stop" : "Start")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(latencyMonitor.isRunning ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                //Data History
                if !history.isEmpty{
                    Divider()
                    
                    HStack{
                        Text("History")
                            .font(.headline)
                        Spacer()
                        Button("Reset", role: .destructive){
                            for item in history { modelContext.delete(item) }
                            try? modelContext.save()
                        }
                    }
                    .padding(.horizontal)
                    
                    List(history) { measurement in
                        VStack(alignment: .leading, spacing: 4){
                            Text(measurement.timestamp.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack { Text("Avg RTT"); Spacer(); Text(String(format: "%.2f ms", measurement.averageRTT)) }
                            HStack { Text("p95 RTT"); Spacer(); Text(String(format: "%.2f%%", measurement.p95RTT)) }
                            HStack { Text("Jitter"); Spacer(); Text(String(format: "%.2f%%", measurement.jitter)) }
                            HStack { Text("Loss"); Spacer(); Text(String(format: "%.2f%%", measurement.packetLoss)) }
                            
                            
                        }
                    }
                    .listStyle(.plain)
                    .frame(maxHeight: 200)
                }
//                Spacer()
            }
            .padding(.top)
            .navigationTitle("Latency Analyzer")
            .onAppear{
                latencyMonitor.modelContext = modelContext
            }
        }
    }
}

    
#Preview{
    LatencyView()
}
