//
//  PDFExporter.swift
//  CST380-Project
//

import UIKit
import SwiftData

/// Generates a PDF diagnostics report from stored SwiftData records and
/// presents the system share sheet so the user can save or share the file.
struct PDFExporter {

    static func export(
        latencyHistory: [LatencyMeasurement],
        dnsHistory: [DNSLookupResult],
        from viewController: UIViewController
    ) {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)  // US Letter
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            var y: CGFloat = 40

            // ── Header ───────────────────────────────────────────────────
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.label
            ]
            let title = "Network Diagnostics Report"
            title.draw(at: CGPoint(x: 40, y: y), withAttributes: titleAttrs)
            y += 36

            let subtitleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.secondaryLabel
            ]
            let dateStr = "Generated: \(Date().formatted(date: .long, time: .shortened))"
            dateStr.draw(at: CGPoint(x: 40, y: y), withAttributes: subtitleAttrs)
            y += 30

            drawDivider(at: y, in: pageRect)
            y += 20

            // ── Latency History ──────────────────────────────────────────
            y = drawSection(
                title: "Latency History",
                rows: latencyHistory.map { m in
                    [
                        m.timestamp.formatted(date: .abbreviated, time: .shortened),
                        String(format: "%.1f ms", m.averageRTT),
                        String(format: "%.1f ms", m.jitter),
                        String(format: "%.1f ms", m.p95RTT),
                        String(format: "%.1f%%", m.packetLoss)
                    ]
                },
                headers: ["Date", "Avg RTT", "Jitter", "p95 RTT", "Loss"],
                startY: y,
                in: pageRect,
                context: ctx
            )
            y += 20

            // ── DNS History ──────────────────────────────────────────────
            y = drawSection(
                title: "DNS Lookup History",
                rows: dnsHistory.map { r in
                    [
                        r.domain,
                        r.ipv4Addresses.first ?? "—",
                        r.ipv6Addresses.first ?? "—",
                        String(format: "%.1f ms", r.resolutionTime)
                    ]
                },
                headers: ["Domain", "IPv4", "IPv6", "Time"],
                startY: y,
                in: pageRect,
                context: ctx
            )
        }

        let tmpURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("diagnostics-\(Int(Date().timeIntervalSince1970)).pdf")
        try? data.write(to: tmpURL)

        let shareVC = UIActivityViewController(activityItems: [tmpURL], applicationActivities: nil)
        if let popover = shareVC.popoverPresentationController {
            popover.sourceView = viewController.view
        }
        viewController.present(shareVC, animated: true)
    }

    // ── Private helpers ──────────────────────────────────────────────────

    @discardableResult
    private static func drawSection(
        title: String,
        rows: [[String]],
        headers: [String],
        startY: CGFloat,
        in pageRect: CGRect,
        context: UIGraphicsPDFRendererContext
    ) -> CGFloat {
        var y = startY
        let margin: CGFloat = 40
        let columnWidth = (pageRect.width - margin * 2) / CGFloat(headers.count)

        let sectionAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.label
        ]
        title.draw(at: CGPoint(x: margin, y: y), withAttributes: sectionAttrs)
        y += 22

        // Header row
        let headerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 10),
            .foregroundColor: UIColor.secondaryLabel
        ]
        UIColor.systemGray5.setFill()
        UIBezierPath(rect: CGRect(x: margin, y: y, width: pageRect.width - margin * 2, height: 20)).fill()

        for (i, header) in headers.enumerated() {
            header.draw(
                at: CGPoint(x: margin + CGFloat(i) * columnWidth + 4, y: y + 4),
                withAttributes: headerAttrs
            )
        }
        y += 22

        // Data rows
        let cellAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.label
        ]
        for (rowIdx, row) in rows.enumerated() {
            // Alternate row background
            if rowIdx % 2 == 0 {
                UIColor.systemGray6.setFill()
                UIBezierPath(rect: CGRect(x: margin, y: y, width: pageRect.width - margin * 2, height: 18)).fill()
            }
            for (i, cell) in row.enumerated() {
                cell.draw(
                    at: CGPoint(x: margin + CGFloat(i) * columnWidth + 4, y: y + 3),
                    withAttributes: cellAttrs
                )
            }
            y += 18

            // Start a new page if we're close to the bottom
            if y > pageRect.height - 80 {
                context.beginPage()
                y = 40
            }
        }

        if rows.isEmpty {
            let emptyAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.italicSystemFont(ofSize: 11),
                .foregroundColor: UIColor.tertiaryLabel
            ]
            "No data recorded yet.".draw(at: CGPoint(x: margin + 4, y: y + 3), withAttributes: emptyAttrs)
            y += 20
        }

        return y
    }

    private static func drawDivider(at y: CGFloat, in pageRect: CGRect) {
        UIColor.separator.setStroke()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 40, y: y))
        path.addLine(to: CGPoint(x: pageRect.width - 40, y: y))
        path.lineWidth = 0.5
        path.stroke()
    }
}
