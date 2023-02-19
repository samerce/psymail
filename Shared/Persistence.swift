import CoreData
import Combine

class PersistenceController: ObservableObject {
  // MARK: - STATIC
  
  static let shared = PersistenceController()
  
  static var preview: PersistenceController = {
    let result = PersistenceController(inMemory: true)
    let viewContext = result.container.viewContext
    
    do {
      try viewContext.save()
    } catch {
      // Replace this implementation with code to handle the error appropriately.
      // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      let nsError = error as NSError
      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
    return result
  }()
  
  // MARK: - INSTANCE
  
  private let inMemory: Bool
  private var subscribers: [AnyCancellable] = []
  private lazy var historyRequestQueue = DispatchQueue(label: "history")
  
  lazy var container: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "psymail")
    
    guard let description = container.persistentStoreDescriptions.first else {
      fatalError("Failed to retrieve a persistent store description.")
    }
    
    if inMemory {
      description.url = URL(fileURLWithPath: "/dev/null")
    }
    
    description.setOption(true as NSNumber,
                          forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

    description.setOption(true as NSNumber,
                          forKey: NSPersistentHistoryTrackingKey)
    
    container.loadPersistentStores { storeDescription, error in
      if let error = error as NSError? {
        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    
    container.viewContext.automaticallyMergesChangesFromParent = false
    container.viewContext.name = "viewContext"
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    container.viewContext.shouldDeleteInaccessibleFaults = true
    
    // Set unused undoManager to nil for macOS (nil by default on iOS) to reduce resource requirements.
    container.viewContext.undoManager = nil
    
    return container
  }()
  
  
  init(inMemory: Bool = false) {
    self.inMemory = inMemory
    
    //    NotificationCenter.default
    //      .publisher(for: .NSPersistentStoreRemoteChange)
    //      .sink { [self] in
    //        storeDidChange($0)
    //      }
    //      .store(in: &subscribers)
  }
  
  func save() {
    let context = container.viewContext
    
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        // Show some error here
      }
    }
  }
  
  // MARK: - PRIVATE
  
  /// Creates and configures a private queue context.
  func newTaskContext() -> NSManagedObjectContext {
    let taskContext = container.newBackgroundContext()
    taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    taskContext.undoManager = nil
    return taskContext
  }
  
  //  private func storeDidChange(_ note: Notification) {
  //    historyRequestQueue.async {
  //      let backgroundContext = self.container.newBackgroundContext()
  //      backgroundContext.performAndWait {
  //        let request = NSPersistentHistoryChangeRequest
  //          .fetchHistory(after: .distantPast)
  //
  //        do {
  //          let result = try backgroundContext.execute(request) as? NSPersistentHistoryResult
  //          guard
  //            let transactions = result?.result as? [NSPersistentHistoryTransaction], !transactions.isEmpty
  //          else {
  //            return
  //          }
  //
  //          print(transactions)
  //        } catch {
  //          // log any errors
  //        }
  //      }
  //    }
  //
  //  }
  
}
