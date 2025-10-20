import Foundation
import Combine
import CoreData

final class CoreDataStack {
    let container: NSPersistentContainer

    init(modelName: String) {
        let managedObjectModel: NSManagedObjectModel
        if let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd"),
           let model = NSManagedObjectModel(contentsOf: modelURL) {
            managedObjectModel = model
        } else {
            managedObjectModel = NSManagedObjectModel()
        }

        container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error = error {
                assertionFailure("Failed to load persistent stores: \(error)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

@MainActor
final class LedgerService: ObservableObject {
    private let coreDataStack: CoreDataStack
    private var cache: [LedgerItem]

    init(coreDataStack: CoreDataStack, seedData: [LedgerItem] = LedgerItem.previewTransactions) {
        self.coreDataStack = coreDataStack
        self.cache = seedData
    }

    func fetchLedgerItems() -> [LedgerItem] {
        cache
    }

    func addTransaction(_ item: LedgerItem) {
        cache.append(item)
        persistPreview(item: item)
    }

    func deleteTransaction(id: LedgerItem.ID) {
        cache.removeAll { $0.id == id }
        persistPreviewState()
    }

    private func persistPreview(item: LedgerItem) {
        let context = coreDataStack.container.viewContext
        context.perform {
            _ = item
        }
    }

    private func persistPreviewState() {
        let context = coreDataStack.container.viewContext
        context.perform { }
    }
}
