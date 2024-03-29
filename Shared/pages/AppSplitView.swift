import Foundation
import SwiftUI
import CoreData

struct AppSplitView: View {
  @Environment(\.managedObjectContext) private var viewContext
  
  private let tabs = ["newsletters", "politics", "marketing", "other"]
  @State private var selectedTab = 0
  
  var body: some View {
    List {
      //        let messages = model.sortedEmails[self.tabs[self.selectedTab]]!
      //        ForEach(messages, id: \.uid) { msg in
      //            let sender = msg.header?.from.displayName ?? "Unknown"
      //            let subject = msg.header?.subject ?? "---"
      //
      //            VStack(alignment: .leading) {
      //                Text(sender)
      //                Text(subject)
      //            }
      //            Spacer()
      //        }
    }
    .toolbar {
      ToolbarItem(placement: .principal) {
        Picker("", selection: $selectedTab) {
          ForEach(Array(tabs.enumerated()), id: \.element) { index, tabName in
            Text(tabName).tag(index)
          }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.top, 8)
      }
    }
  }
  
  //    private func addItem() {
  //        withAnimation {
  //            let newItem = Item(context: viewContext)
  //            newItem.timestamp = Date()
  //
  //            do {
  //                try viewContext.save()
  //            } catch {
  //                // Replace this implementation with code to handle the error appropriately.
  //                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
  //                let nsError = error as NSError
  //                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
  //            }
  //        }
  //    }
  //
  //    private func deleteItems(offsets: IndexSet) {
  //        withAnimation {
  //            offsets.map { items[$0] }.forEach(viewContext.delete)
  //
  //            do {
  //                try viewContext.save()
  //            } catch {
  //                // Replace this implementation with code to handle the error appropriately.
  //                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
  //                let nsError = error as NSError
  //                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
  //            }
  //        }
  //    }
  
  private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
  }()
  
}
