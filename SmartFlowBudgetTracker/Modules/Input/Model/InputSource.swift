import Foundation

enum InputSource: String, CaseIterable, Identifiable, Codable {
    case manual
    case receiptScan
    case bankSync
    case emailForwarding

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .manual: return "Manual Entry"
        case .receiptScan: return "Receipt Scan"
        case .bankSync: return "Bank Sync"
        case .emailForwarding: return "Email Forwarding"
        }
    }
}
