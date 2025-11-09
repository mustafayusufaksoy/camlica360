import SwiftUI
import Charts

/// Monthly chart card component
struct MonthlyChartCard: View {
    let chartData: [MonthlyData]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Chart title
            HStack {
                Text("Onaylanan İzin Görüntüleme")
                    .font(AppFonts.smMedium)
                    .foregroundColor(AppColors.black)

                Spacer()
            }

            // Bar chart
            Chart(chartData) { item in
                BarMark(
                    x: .value("Ay", item.month),
                    y: .value("Değer", item.value)
                )
                .foregroundStyle(AppColors.primary600)
                .cornerRadius(4)
            }
            .frame(height: 250)
            .chartYScale(domain: 0...100)
            .chartYAxis {
                AxisMarks(position: .leading, values: [0, 20, 40, 60, 80, 100]) { value in
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
