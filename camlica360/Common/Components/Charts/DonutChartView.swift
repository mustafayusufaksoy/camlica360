import SwiftUI

/// Donut chart component for displaying data segments
struct DonutChartView: View {
    let segments: [ChartSegment]
    let size: CGFloat
    let lineWidth: CGFloat

    var total: Int {
        segments.reduce(0) { $0 + $1.value }
    }

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.1), lineWidth: lineWidth)

            // Data segments
            if total > 0 {
                ForEach(Array(segments.enumerated()), id: \.element.id) { index, segment in
                    DonutSegment(
                        startAngle: startAngle(for: index),
                        endAngle: endAngle(for: index),
                        color: segment.color,
                        lineWidth: lineWidth
                    )
                }
            }

            // Center content
            VStack(spacing: 2) {
                Text("\(total)")
                    .font(.system(size: size < 150 ? 24 : 32, weight: .bold))
                    .foregroundColor(Color(hex: "0F0F0F"))

                Text("Toplam")
                    .font(.system(size: size < 150 ? 11 : 14))
                    .foregroundColor(Color(hex: "6C7072"))
            }
        }
        .frame(width: size, height: size)
    }

    private func startAngle(for index: Int) -> Angle {
        let previousValues = segments.prefix(index).reduce(0) { $0 + $1.value }
        let percentage = Double(previousValues) / Double(total)
        return .degrees(-90 + (percentage * 360))
    }

    private func endAngle(for index: Int) -> Angle {
        let valuesUpToIndex = segments.prefix(index + 1).reduce(0) { $0 + $1.value }
        let percentage = Double(valuesUpToIndex) / Double(total)
        return .degrees(-90 + (percentage * 360))
    }
}

/// Individual donut segment
struct DonutSegment: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    let lineWidth: CGFloat

    var body: some View {
        Circle()
            .trim(from: 0, to: 1)
            .stroke(
                color,
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )
            .rotationEffect(startAngle)
            .mask(
                Circle()
                    .trim(from: 0, to: CGFloat((endAngle.degrees - startAngle.degrees) / 360))
                    .stroke(Color.white, lineWidth: lineWidth)
            )
    }
}

/// Chart segment data model
struct ChartSegment: Identifiable {
    let id = UUID()
    let label: String
    let value: Int
    let color: Color
}

/// Chart legend item
struct ChartLegendItem: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)

            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "0F0F0F"))

            Text("\(value)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "6C7072"))

            Spacer()
        }
    }
}

#Preview {
    VStack {
        DonutChartView(
            segments: [
                ChartSegment(label: "Bekleyen", value: 5, color: .orange),
                ChartSegment(label: "Onaylanan", value: 3, color: .green),
                ChartSegment(label: "Reddedilen", value: 2, color: .red)
            ],
            size: 200,
            lineWidth: 40
        )
    }
}
