//
//  DashboardModels.swift
//  ImageExt
//
//  Created by yakang wang on 2026/2/4.
//

import Foundation

struct DashboardData {
    var assumptions: String
    var lastUpdated: Date
    var kpis: [KpiMetric]
    var trends: [TrendSeries]
    var breakdown: [BreakdownRow]
}

struct KpiMetric: Identifiable {
    let id = UUID()
    var title: String
    var value: String
    var delta: Double
    var deltaLabel: String
}

struct TrendSeries: Identifiable {
    let id = UUID()
    var title: String
    var subtitle: String
    var points: [Double]
    var valueLabel: String
    var delta: Double
}

struct BreakdownRow: Identifiable {
    let id = UUID()
    var name: String
    var primary: String
    var secondary: String
    var delta: Double
}

final class DashboardViewModel: ObservableObject {
    @Published var data: DashboardData

    init() {
        data = DashboardViewModel.placeholderData()
    }

    func load() {
        // TODO: Replace with real data source (local JSON, database, or API)
        data = DashboardViewModel.placeholderData()
    }

    private static func placeholderData() -> DashboardData {
        DashboardData(
            assumptions: "Assuming generic product analytics KPIs with placeholder data.",
            lastUpdated: Date(),
            kpis: [
                KpiMetric(title: "Daily Active Users", value: "12.4k", delta: 4.2, deltaLabel: "vs last 7 days"),
                KpiMetric(title: "Conversion Rate", value: "3.8%", delta: -0.6, deltaLabel: "vs last 7 days"),
                KpiMetric(title: "Revenue", value: "$48.2k", delta: 6.1, deltaLabel: "vs last 7 days"),
                KpiMetric(title: "Error Rate", value: "0.42%", delta: -0.2, deltaLabel: "vs last 7 days")
            ],
            trends: [
                TrendSeries(
                    title: "Acquisition Trend",
                    subtitle: "New users",
                    points: [12, 18, 15, 22, 26, 21, 28, 32, 30, 35, 38, 34],
                    valueLabel: "+2.1k",
                    delta: 5.1
                ),
                TrendSeries(
                    title: "Activation Trend",
                    subtitle: "First action",
                    points: [8, 10, 9, 12, 11, 13, 14, 13, 15, 17, 16, 18],
                    valueLabel: "+1.4k",
                    delta: 3.4
                )
            ],
            breakdown: [
                BreakdownRow(name: "Organic", primary: "38%", secondary: "4.7k", delta: 2.1),
                BreakdownRow(name: "Paid", primary: "27%", secondary: "3.3k", delta: -1.4),
                BreakdownRow(name: "Referral", primary: "19%", secondary: "2.4k", delta: 0.6),
                BreakdownRow(name: "Direct", primary: "16%", secondary: "2.0k", delta: -0.2)
            ]
        )
    }
}
