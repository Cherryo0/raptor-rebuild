import Foundation

/// Updater: checks a version endpoint and reports whether an update exists.
/// It NEVER downloads or installs a binary in this project — the download
/// path is intentionally absent. See docs/modules/13-updater-versioning.md.
struct UpdateCheckResult: Equatable {
    let currentVersion: String
    let latestVersion: String?
    let updateAvailable: Bool
    let downloadURL: URL?
}

final class UpdaterService {
    let currentVersion: String
    private let apiClient: ApiClient

    init(currentVersion: String = "0.1.0", apiClient: ApiClient = ApiClient()) {
        self.currentVersion = currentVersion
        self.apiClient = apiClient
    }

    func checkForUpdates() async -> UpdateCheckResult {
        do {
            let info = try await apiClient.fetchVersion()
            let latest = info.version ?? info.clientVersionUpload
            return UpdateCheckResult(
                currentVersion: currentVersion,
                latestVersion: latest,
                updateAvailable: latest != currentVersion,
                downloadURL: nil // No download URL is ever followed by this project.
            )
        } catch {
            return UpdateCheckResult(currentVersion: currentVersion, latestVersion: nil, updateAvailable: false, downloadURL: nil)
        }
    }
}
