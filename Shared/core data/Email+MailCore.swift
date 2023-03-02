import Foundation
import CoreData
import MailCore


private let accountCtrl = AccountController.shared


extension Email {
  
  var moc: NSManagedObjectContext? { managedObjectContext }
  var session: MCOIMAPSession? {
    if let account = account {
      return accountCtrl.sessions[account]
    }
    else { return nil }
  }
  var uidSet: MCOIndexSet {
    MCOIndexSet(index: UInt64(uid))
  }
  
  
  private func runOperation(_ op: MCOIMAPOperation) async throws {
    let _: () = try await withCheckedThrowingContinuation { continuation in
      op.start { error in
        if let error = error {
          continuation.resume(throwing: error)
        } else {
          continuation.resume()
        }
      }
    }
  }
  
  private func sessionForType(_ accountType: AccountType) -> MCOIMAPSession {
    switch accountType {
      case .gmail:
        return GmailSession()
    }
  }
  
}

// MARK: - HTML

extension Email {
  
  func fetchHtml() async throws {
    guard html.isEmpty
    else { return }
    
    html = try await self.bodyHtml()
    
    try self.moc?.save()
  }
  
  private func bodyHtml() async throws -> String {
    guard let fetchMessage = session?.fetchParsedMessageOperation(withFolder: DefaultFolder,
                                                                  uid: UInt32(uid))
    else {
      throw PsyError.unexpectedError(message: "failed to create fetch HTML operation")
    }
    
    return try await withCheckedThrowingContinuation { continuation in
      fetchMessage.start() { error, parser in
        if let error = error {
          continuation.resume(throwing: error)
        } else {
          continuation.resume(returning: parser?.htmlBodyRendering() ?? "")
        }
      }
    }
  }
  
}


// MARK: - FLAGS

extension Email {
  
  func markSeen() async throws {
    try await updateFlags(.seen, operation: .add)
  }
  
  func markFlagged() async throws {
    try await updateFlags(.flagged, operation: .add)
  }
  
  func updateFlags(_ flags: MCOMessageFlag, operation: MCOIMAPStoreFlagsRequestKind) async throws {
    print("updating imap flags")
    
    guard let updateFlags = session!.storeFlagsOperation( // TODO: handle this force unwrap
      withFolder: DefaultFolder,
      uids: uidSet,
      kind: .add,
      flags: .seen
    ) else {
      throw PsyError.unexpectedError(message: "error creating update flags operation")
    }
    
    try await runOperation(updateFlags)
    addFlags(.seen) // TODO: update from server instead?
  }
  
}

// MARK: - LABELS

extension Email {
  
  func moveToTrash() async throws {
    print("moving emails to trash")
    try await updateLabels(["\\Trash"], operation: .add)
    
    guard let expunge = session?.expungeOperation("INBOX")
    else {
      throw PsyError.unexpectedError(message: "error creating expunge operation")
    }
    try await runOperation(expunge)

    // TODO: replace this with refetch email from server so gmailLabels update
    gmailLabels.insert("\\Trash")
    addFlags(.deleted)
    trashed = true
  }
  
  func addLabels(_ labels: [String]) async throws {
    print("adding imap labels \(labels)")
    try await updateLabels(labels, operation: .add)
    labels.forEach{ gmailLabels.insert($0) }
  }
  
  func removeLabels(_ labels: [String]) async throws {
    print("removing imap labels \(labels)")
    try await updateLabels(labels, operation: .remove)
    labels.forEach { gmailLabels.remove($0) }
  }
  
  func updateLabels(_ labels: [String], operation: MCOIMAPStoreFlagsRequestKind) async throws {
    guard let addTrashLabel = session?.storeLabelsOperation(withFolder: DefaultFolder,
                                                            uids: uidSet,
                                                            kind: .add,
                                                            labels: labels)
    else {
      throw PsyError.unexpectedError(message: "error creating label update operations")
    }

    try await runOperation(addTrashLabel)
  }
  
}