import Foundation

/// Licensing client (Sellix key + HWID). Stub for the live endpoint.
/// Keys are never put in a URL query string and never logged.
/// See docs/modules/03-licensing-sellix-hwid.md.
enum LicensingError: Error, LocalizedError {
    case invalidKeyFormat
    case notImplemented
    case network(Error)
    case server(message: String)

    var errorDescription: String? {
        switch self {
        case .invalidKeyFormat: return "Key format is invalid."
        case .notImplemented: return "Live licence activation is not implemented in this clean-room stub."
        case .network(let error): return "Network error: \(error.localizedDescription)"
        case .server(let message): return "Server error: \(message)"
        }
    }
}

final class LicensingService {
    private let apiClient: ApiClient

    init(apiClient: ApiClient = ApiClient()) { self.apiClient = apiClient }

    /// A Sellix-style key is non-empty and contains no whitespace. Format
    /// validation is local only; live activation is a stub.
    func isPlausibleKey(_ key: String) -> Bool {
        !key.isEmpty && key.rangeOfCharacter(from: .whitespacesAndNewlines) == nil && key.count >= 8
    }

    func activate(key: String) async throws -> LicenceState {
        guard isPlausibleKey(key) else { throw LicensingError.invalidKeyFormat }
        // Live activation intentionally not implemented — ApiClient returns .notImplemented.
        return try await apiClient.activateLicence(key: key)
    }

    /// Local device identifier for display only. It is computed locally and
    /// NEVER uploaded by this code. The original exfiltrated HWID to a
    /// whitelist endpoint; this rebuild does not.
    static func localDeviceIdentifier() -> String {
        let host = Host.current().localizedName ?? "unknown-host"
        return "local-\(abs(host.hashValue))"
    }
}
