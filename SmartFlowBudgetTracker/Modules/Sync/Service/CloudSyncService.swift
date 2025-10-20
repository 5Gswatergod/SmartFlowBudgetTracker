import Foundation
import Combine
#if canImport(CloudKit)
import CloudKit
#endif

@MainActor
final class CloudSyncService: ObservableObject {
    enum Backend {
        case simulated
        #if canImport(CloudKit)
        case cloudKit(CKContainer)
        #endif
    }

    @Published private(set) var status: SyncStatus = SyncStatus(state: .idle, lastSync: nil, message: nil)

    private let backend: Backend
    private let minimumSyncDelayNanoseconds: UInt64

    init(
        containerIdentifier: String? = nil,
        usesCloudKit: Bool = false,
        minimumSyncDelayNanoseconds: UInt64 = 180_000_000
    ) {
        self.minimumSyncDelayNanoseconds = minimumSyncDelayNanoseconds

        #if canImport(CloudKit)
        if usesCloudKit {
            if let identifier = containerIdentifier, !identifier.isEmpty {
                backend = .cloudKit(CKContainer(identifier: identifier))
            } else {
                backend = .cloudKit(CKContainer.default())
            }
        } else {
            backend = .simulated
        }
        #else
        backend = .simulated
        #endif
    }

    func syncNow() async {
        status = SyncStatus(state: .syncing, lastSync: status.lastSync, message: "Syncing with iCloud…")

        switch backend {
        case .simulated:
            await performSimulatedSync()
        #if canImport(CloudKit)
        case .cloudKit(let container):
            await performCloudKitSync(using: container)
        #endif
        }
    }

    private func performSimulatedSync() async {
        do {
            try await Task.sleep(nanoseconds: minimumSyncDelayNanoseconds)
            status = SyncStatus(state: .success, lastSync: .now, message: "All data is up to date")
        } catch {
            status = SyncStatus(state: .failure, lastSync: status.lastSync, message: error.localizedDescription)
        }
    }

    #if canImport(CloudKit)
    private func performCloudKitSync(using container: CKContainer) async {
        do {
            try await Task.sleep(nanoseconds: minimumSyncDelayNanoseconds)
            _ = try await container.accountStatus()
            status = SyncStatus(state: .success, lastSync: .now, message: "All data is up to date")
        } catch let cloudError as CKError where cloudError.code == .missingEntitlement {
            status = SyncStatus(
                state: .failure,
                lastSync: status.lastSync,
                message: "CloudKit entitlement missing. Update provisioning or use simulated sync mode."
            )
        } catch {
            status = SyncStatus(state: .failure, lastSync: status.lastSync, message: error.localizedDescription)
        }
    }
    #endif
}
