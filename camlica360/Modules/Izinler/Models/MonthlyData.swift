import Foundation

/// Monthly chart data model
struct MonthlyData: Identifiable {
    let id = UUID()
    let month: String
    let value: Double
}
