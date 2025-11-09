import Foundation

/// Network error types
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case encodingError
    case serverError(Int, String)
    case unauthorized
    case forbidden
    case notFound
    case timeout
    case noInternetConnection
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Geçersiz URL"
        case .noData:
            return "Veri alınamadı"
        case .decodingError:
            return "Veri işlenirken hata oluştu"
        case .encodingError:
            return "Veri gönderilirken hata oluştu"
        case .serverError(let code, let message):
            return "Sunucu hatası (\(code)): \(message)"
        case .unauthorized:
            return "Yetkisiz işlem. Lütfen tekrar giriş yapın."
        case .forbidden:
            return "Bu işlem için yetkiniz yok"
        case .notFound:
            return "İstenen kaynak bulunamadı"
        case .timeout:
            return "İstek zaman aşımına uğradı"
        case .noInternetConnection:
            return "İnternet bağlantısı yok"
        case .unknown(let error):
            return "Beklenmeyen hata: \(error.localizedDescription)"
        }
    }
}
