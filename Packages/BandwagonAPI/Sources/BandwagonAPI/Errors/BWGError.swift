import Foundation

/// KiwiVM API 错误体系
public enum BWGError: LocalizedError, Sendable, Equatable {
    case invalidURL
    case networkError(String)
    case apiError(code: Int, message: String)
    case decodingError(String)
    case invalidCredentials
    case rateLimited(resetTimestamp: Date?)
    case unknown

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL."
        case .networkError(let details):
            return "Network error: \(details)"
        case .apiError(let code, let message):
            return "API error (\(code)): \(message)"
        case .decodingError(let details):
            return "Failed to parse response: \(details)"
        case .invalidCredentials:
            return "Invalid VEID or API Key."
        case .rateLimited(let reset):
            if let reset {
                return "API rate limit reached. Resets at \(reset.formatted())."
            }
            return "API rate limit reached. Please try again later."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
