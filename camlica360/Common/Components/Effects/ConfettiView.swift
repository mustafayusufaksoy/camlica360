import SwiftUI

/// Confetti animation view for celebration moments
struct ConfettiView: View {
    @State private var confetti: [ConfettiPiece] = []
    let colors: [Color] = [
        .red, .blue, .green, .yellow, .orange, .purple, .pink,
        Color(hex: "FF6B6B"), Color(hex: "4ECDC4"), Color(hex: "45B7D1")
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confetti) { piece in
                    ConfettiShape()
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size)
                        .position(piece.position)
                        .rotationEffect(piece.rotation)
                }
            }
            .onAppear {
                startConfetti(in: geometry.size)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func startConfetti(in size: CGSize) {
        // Generate confetti pieces
        for i in 0..<80 {
            let delay = Double(i) * 0.02
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let piece = ConfettiPiece(
                    id: UUID(),
                    color: colors.randomElement() ?? .red,
                    size: CGFloat.random(in: 6...12),
                    position: CGPoint(
                        x: CGFloat.random(in: 0...size.width),
                        y: -20
                    ),
                    rotation: Angle(degrees: Double.random(in: 0...360))
                )
                confetti.append(piece)
                animatePiece(piece, in: size)
            }
        }
    }

    private func animatePiece(_ piece: ConfettiPiece, in size: CGSize) {
        withAnimation(
            Animation
                .linear(duration: Double.random(in: 3...5))
                .repeatForever(autoreverses: false)
        ) {
            if let index = confetti.firstIndex(where: { $0.id == piece.id }) {
                confetti[index].position.y = size.height + 50
                confetti[index].position.x += CGFloat.random(in: -100...100)
                confetti[index].rotation = Angle(degrees: Double.random(in: 360...720))
            }
        }
    }
}

/// Single confetti piece data
struct ConfettiPiece: Identifiable {
    let id: UUID
    let color: Color
    let size: CGFloat
    var position: CGPoint
    var rotation: Angle
}

/// Confetti shape (circle or rectangle)
struct ConfettiShape: Shape {
    func path(in rect: CGRect) -> Path {
        // Random shape: circle or rectangle
        if Bool.random() {
            return Circle().path(in: rect)
        } else {
            return Rectangle().path(in: rect)
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.green.opacity(0.3)
        ConfettiView()
    }
}
