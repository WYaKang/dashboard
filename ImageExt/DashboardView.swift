//
//  DashboardView.swift
//  ImageExt
//
//  Created by yakang wang on 2026/2/4.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        ZStack {
            Color.dashboardBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    kpiGrid
                    trendsSection
                    breakdownSection
                }
                .padding(20)
            }
        }
        .onAppear {
            viewModel.load()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dashboard")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.dashboardText)
                    Text(viewModel.data.assumptions)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.dashboardMuted)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text("Last 7 days")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.dashboardPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.dashboardPrimary.opacity(0.12))
                        .clipShape(Capsule())

                    Text("Updated \(formattedDate(viewModel.data.lastUpdated))")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.dashboardMuted)
                }
            }
        }
    }

    private var kpiGrid: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]

        return LazyVGrid(columns: columns, spacing: 14) {
            ForEach(viewModel.data.kpis) { metric in
                KpiCard(metric: metric)
            }
        }
    }

    private var trendsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Trends", subtitle: "Key movement over time")

            GeometryReader { proxy in
                let useHorizontal = proxy.size.width > 680
                Group {
                    if useHorizontal {
                        HStack(spacing: 14) {
                            ForEach(viewModel.data.trends) { series in
                                TrendCard(series: series)
                            }
                        }
                    } else {
                        VStack(spacing: 14) {
                            ForEach(viewModel.data.trends) { series in
                                TrendCard(series: series)
                            }
                        }
                    }
                }
            }
            .frame(height: viewModel.data.trends.count > 1 ? 220 : 200)
        }
    }

    private var breakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Breakdown", subtitle: "Top channels and contribution")
            BreakdownTable(rows: viewModel.data.breakdown)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

private struct SectionHeader: View {
    var title: String
    var subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.dashboardText)
            Text(subtitle)
                .font(.system(size: 12))
                .foregroundStyle(Color.dashboardMuted)
        }
    }
}

private struct KpiCard: View {
    var metric: KpiMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(metric.title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.dashboardMuted)
            Text(metric.value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color.dashboardText)
            HStack(spacing: 6) {
                DeltaPill(delta: metric.delta)
                Text(metric.deltaLabel)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.dashboardMuted)
            }
        }
        .cardStyle()
    }
}

private struct TrendCard: View {
    var series: TrendSeries

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(series.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.dashboardText)
                    Text(series.subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.dashboardMuted)
                }
                Spacer()
                DeltaPill(delta: series.delta)
            }

            MiniTrendChart(points: series.points)
                .frame(height: 80)

            HStack {
                Text(series.valueLabel)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.dashboardText)
                Spacer()
                Text(series.delta >= 0 ? "Up" : "Down")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.dashboardMuted)
            }
        }
        .cardStyle()
    }
}

private struct BreakdownTable: View {
    var rows: [BreakdownRow]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Channel")
                Spacer()
                Text("Share")
                Spacer().frame(width: 24)
                Text("Volume")
                Spacer().frame(width: 24)
                Text("Delta")
            }
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Color.dashboardMuted)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            Divider()

            ForEach(rows) { row in
                HStack {
                    Text(row.name)
                        .foregroundStyle(Color.dashboardText)
                    Spacer()
                    Text(row.primary)
                        .foregroundStyle(Color.dashboardText)
                    Spacer().frame(width: 24)
                    Text(row.secondary)
                        .foregroundStyle(Color.dashboardText)
                    Spacer().frame(width: 24)
                    DeltaPill(delta: row.delta, compact: true)
                }
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)

                if row.id != rows.last?.id {
                    Divider()
                }
            }
        }
        .cardStyle()
    }
}

private struct DeltaPill: View {
    var delta: Double
    var compact: Bool = false

    var body: some View {
        let isPositive = delta >= 0
        let label = String(format: "%@%.1f%%", isPositive ? "+" : "", delta)

        return Text(label)
            .font(.system(size: compact ? 10 : 11, weight: .bold, design: .rounded))
            .foregroundStyle(isPositive ? Color.dashboardSuccess : Color.dashboardDanger)
            .padding(.horizontal, compact ? 6 : 8)
            .padding(.vertical, compact ? 4 : 5)
            .background((isPositive ? Color.dashboardSuccess : Color.dashboardDanger).opacity(0.12))
            .clipShape(Capsule())
    }
}

private struct MiniTrendChart: View {
    var points: [Double]

    var body: some View {
        GeometryReader { proxy in
            let height = proxy.size.height
            let width = proxy.size.width
            let maxPoint = points.max() ?? 1
            let minPoint = points.min() ?? 0
            let range = max(maxPoint - minPoint, 1)

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.dashboardPrimary.opacity(0.06))

                Path { path in
                    guard !points.isEmpty else { return }

                    if points.count == 1 {
                        let y = height - (height * CGFloat((points[0] - minPoint) / range))
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                        return
                    }

                    for index in points.indices {
                        let x = width * CGFloat(index) / CGFloat(points.count - 1)
                        let y = height - (height * CGFloat((points[index] - minPoint) / range))
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(Color.dashboardPrimary, style: StrokeStyle(lineWidth: 2, lineJoin: .round))
            }
        }
    }
}

private extension View {
    func cardStyle() -> some View {
        self
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.black.opacity(0.04), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 6)
    }
}

private extension Color {
    static let dashboardPrimary = Color(red: 30 / 255, green: 64 / 255, blue: 175 / 255)
    static let dashboardSecondary = Color(red: 59 / 255, green: 130 / 255, blue: 246 / 255)
    static let dashboardAccent = Color(red: 245 / 255, green: 158 / 255, blue: 11 / 255)
    static let dashboardBackground = Color(red: 248 / 255, green: 250 / 255, blue: 252 / 255)
    static let dashboardText = Color(red: 30 / 255, green: 58 / 255, blue: 138 / 255)
    static let dashboardMuted = Color(red: 100 / 255, green: 116 / 255, blue: 139 / 255)
    static let dashboardSuccess = Color(red: 16 / 255, green: 185 / 255, blue: 129 / 255)
    static let dashboardDanger = Color(red: 239 / 255, green: 68 / 255, blue: 68 / 255)
}

#Preview {
    DashboardView()
}
