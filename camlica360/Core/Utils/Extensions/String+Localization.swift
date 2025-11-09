import Foundation

extension String {
    /// Returns the localized string for the key
    var localized: String {
        NSLocalizedString(self, comment: "")
    }

    /// Localized string with format arguments
    func localized(with arguments: CVarArg...) -> String {
        let localized = NSLocalizedString(self, comment: "")
        return String(format: localized, arguments: arguments)
    }
}
