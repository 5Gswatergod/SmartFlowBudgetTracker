import Foundation

struct SyncStatus: Equatable {
    enum State: String {
        case idle
        case syncing
        case success
        case failure
    }

    var state: State
    var lastSync: Date?
    var message: String?
}
