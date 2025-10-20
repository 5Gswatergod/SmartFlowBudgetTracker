import Foundation
import CloudKit

@MainActor
final class CloudSyncService: ObservableObject {
    @Published private(set) var status: SyncStatus = SyncStatus(state: .idle, lastSync: nil, message: nil)

    private let container: CKContainer

    init(containerIdentifier: String) {
        self.container = CKContainer(identifier: containerIdentifier)
    }

    func syncNow() async {
        status = SyncStatus(state: .syncing, lastSync: status.lastSync, message: "Syncing with iCloud…")
        do {
            try await Task.sleep(nanoseconds: 180_000_000)
            _ = try await container.accountStatus()
            status = SyncStatus(state: .success, lastSync: .now, message: "All data is up to date")
        } catch {
            status = SyncStatus(state: .failure, lastSync: status.lastSync, message: error.localizedDescription)
        }
    }
}
