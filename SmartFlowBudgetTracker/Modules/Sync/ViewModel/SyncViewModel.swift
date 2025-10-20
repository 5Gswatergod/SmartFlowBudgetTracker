import Foundation
import Combine

@MainActor
final class SyncViewModel: ObservableObject {
    @Published private(set) var status: SyncStatus

    private let service: CloudSyncService

    init(service: CloudSyncService) {
        self.service = service
        self.status = service.status
    }

    func refresh() {
        Task { @MainActor in
            await service.syncNow()
            status = service.status
        }
    }
}
