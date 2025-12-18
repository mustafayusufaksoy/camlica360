import SwiftUI
import Charts

/// Monthly chart card component
struct MonthlyChartCard: View {
    let chartData: [MonthlyData]

    // Filter out NaN values and ensure valid data
    private var validChartData: [MonthlyData] {
        chartData.filter { !$0.value.isNaN && !$0.value.isInfinite }
    }

    // Calculate max value for dynamic Y-axis scale
    private var maxValue: Double {
        let max = validChartData.map { $0.value }.max() ?? 0
        // Round up to nearest 10 for better scale
        return max > 0 ? ceil(max / 10) * 10 : 100
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Chart title
            HStack {
                Text("Onaylanan İzin Görüntüleme")
                    .font(AppFonts.smMedium)
                    .foregroundColor(AppColors.black)

                Spacer()
            }

            // Bar chart or empty state
            if validChartData.isEmpty {
                // Empty state
                VStack(spacing: AppSpacing.md) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.neutral300)
                    Text("Henüz onaylanmış izin bulunmuyor")
                        .font(AppFonts.xsRegular)
                        .foregroundColor(AppColors.neutral600)
                }
                .frame(height: 250)
                .frame(maxWidth: .infinity)
            } else {
                Chart(validChartData) { item in
                    BarMark(
                        x: .value("Ay", item.month),
                        y: .value("Değer", item.value)
                    )
                    .foregroundStyle(AppColors.primary600)
                    .cornerRadius(4)
                }
                .frame(height: 250)
                .chartYScale(domain: 0...maxValue)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                            .foregroundStyle(AppColors.neutral200)
                        AxisValueLabel()
                            .font(AppFonts.xsRegular)
                            .foregroundStyle(AppColors.neutral600)
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .font(AppFonts.xsRegular)
                            .foregroundStyle(AppColors.neutral600)
                    }
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.radiusMd)
    }
}

// MARK: - Preview

#Preview {
    MonthlyChartCard(chartData: [
        MonthlyData(month: "Oca", value: 25),
        MonthlyData(month: "Şub", value: 75),
        MonthlyData(month: "Mar", value: 50)
    ])
    .padding()
    .background(AppColors.background)
}
