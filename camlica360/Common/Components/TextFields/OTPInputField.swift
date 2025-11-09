import SwiftUI

/// OTP input field for single digit entry
struct OTPInputField: View {
    @Binding var value: String
    var shouldBeFocused: Bool = false
    @FocusState private var isFocused: Bool
    var onMovedToNext: () -> Void = { }
    var onMovedToPrevious: () -> Void = { }

    var body: some View {
        TextField("", text: $value)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .font(AppFonts.mdMedium)
            .foregroundColor(AppColors.black)
            .background(AppColors.white)
            .cornerRadius(AppSpacing.radiusMd)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.radiusMd)
                    .stroke(value.isEmpty ? AppColors.neutral200 : AppColors.primary950, lineWidth: 1)
            )
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
            .focused($isFocused)
            .onChange(of: shouldBeFocused) { oldValue, newValue in
                if newValue {
                    isFocused = true
                }
            }
            .onChange(of: value) { oldValue, newValue in
                // Handle multi-character paste - keep only last digit
                if newValue.count > 1 {
                    value = String(newValue.last ?? " ")
                }
                // Handle non-numeric input
                else if !newValue.allSatisfy({ $0.isNumber }) {
                    value = oldValue
                }
                // Auto move to next field when digit entered
                else if newValue.count == 1 && !newValue.isEmpty && oldValue.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        onMovedToNext()
                    }
                }
                // Move to previous field when backspace pressed
                else if oldValue.count == 1 && newValue.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        onMovedToPrevious()
                    }
                }
            }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 8) {
            ForEach(0..<6, id: \.self) { _ in
                OTPInputField(value: .constant("5"))
            }
        }
    }
    .padding()
}
