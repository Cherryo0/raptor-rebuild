import Foundation

/// HTTPS API client for version + licence endpoints.
/// All live calls are stubs in this rebuild (no endpoint is contacted).
/// When a real endpoint is configured, it must be HTTPS and must accept
/// keys via POST body / Authorization header — never a query string.
struct VersionInfo: Codable, Equatable {
    let channel: String
    let clientVersionUpload: String
    let version: String?
}

enum ApiError: Error, LocalizedError {
    case notImplemented
    case invalidURL
    case http(status: Int)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .notImplemented: return "Live API call is not implemented in this clean-room stub."
        case .invalidURL: return "Configured API URL is invalid (HTTPS required)."
        case .http(let status): return "HTTP error: \(status)"
        case .decoding(let error): return "Decoding error: \(error.localizedDescription)"
        }
    }
}

final class ApiClient {
    let baseURL: URL?

    init(baseURLString: String? = nil) {
        if let baseURLString, let url = URL(string: baseURLString), url.scheme == "https" {
            self.baseURL = url
        } else {
            self.baseURL = nil
        }
    }

    func fetchVersion() async throws -> VersionInfo {
        throw ApiError.notImplemented
    }

    func activateLicence(key: String) async throws -> LicenceState {
        _ = key // Key is accepted only to validate format upstream; it is never sent anywhere here.
        throw LicensingError.notImplemented
    }

    /// Builds a POST request (used by the full implementation). Kept here so
    /// the request shape is reviewable without ever being sent in the stub.
    func licenceActivationRequest(key: String) throws -> URLRequest {
        guard let baseURL else { throw ApiError.invalidURL }
        var request = URLRequest(url: baseURL.appendingPathComponent("sellix"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(["hwid": LicensingService.localDeviceIdentifier()])
        return request
    }
}
