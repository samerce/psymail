import SwiftUI
import SwiftUIKit
import UIKit
import CoreData


struct InboxView: View {
  @StateObject private var mailCtrl = MailController.shared
  @State private var bundle = Bundles[0]
  @State private var emailIds: Set<NSManagedObjectID> = []
  @State private var sheetPresented = true
  @State private var appSheetMode: AppSheetMode = .inboxTools
  @State private var editMode: EditMode = .inactive
  
  @FetchRequest(fetchRequest: Email.fetchRequestForBundle())
  private var emailResults: FetchedResults<Email>
  
  // MARK: - VIEW
  
  var body: some View {
    NavigationSplitView {
      EmailList
    } detail: {
      if emailIds.isEmpty {
        Text("no message selected")
      } else {
        EmailDetailView(id: emailIds.first!)
      }
    }
    .onChange(of: bundle) { _bundle in
      emailResults.nsPredicate = Email.predicateForBundle(_bundle)
    }
    .onChange(of: emailIds) { _ in
      if editMode.isEditing { return }
      withAnimation {
        switch (emailIds.isEmpty) {
          case true: appSheetMode = .inboxTools
          case false: appSheetMode = .emailTools
        }
      }
    }
    .sheet(isPresented: $sheetPresented) {
      AppSheetView(mode: $appSheetMode, bundle: $bundle)
    }
  }
  
  private var EmailList: some View {
    List(emailResults, id: \.objectID, selection: $emailIds) {
      EmailListRow(email: $0)
    }
    .listStyle(.plain)
    .listRowInsets(.none)
    .navigationBarTitleDisplayMode(.inline)
    .environment(\.editMode, $editMode)
    .refreshable { mailCtrl.fetchLatest() }
    .toolbar(content: ToolbarContent)
//    .onChange(of: emailResults.nsPredicate) { _ in
//      scrollProxy.scrollTo(emailResults.first?.objectID)
//    }
    .safeAreaInset(edge: .bottom) {
      Spacer().frame(height: appSheetDetents.min)
    }
  }
  
  @ToolbarContentBuilder
  private func ToolbarContent() -> some ToolbarContent {
    ToolbarItem(placement: .navigationBarLeading) {
      Button(action: {}) {
        SystemImage("rectangle.grid.1x2", size: 20)
      }
    }
    ToolbarItem(placement: .principal) {
      Text(bundle == "everything" ? "inbox" : bundle)
        .font(.system(size: 27, weight: .black))
        .padding(.bottom, 6)
    }
    ToolbarItem(placement: .navigationBarTrailing) {
      Button {
        withAnimation {
          editMode = editMode.isEditing ? .inactive : .active
        }
      } label: {
        Text(editMode.isEditing ? "Done" : "Edit")
          .animation(nil)
          .foregroundColor(.psyAccent)
      }
    }
  }
  
  private func SystemImage(_ name: String, size: CGFloat) -> some View {
    Image(systemName: name)
      .resizable()
      .aspectRatio(contentMode: .fit)
      .font(.system(size: size, weight: .light, design: .default))
      .foregroundColor(.psyAccent)
      .frame(width: size, height: size)
      .contentShape(Rectangle())
      .clipped()
  }
  
}


struct EmailListView_Previews: PreviewProvider {
  static var previews: some View {
    InboxView()
  }
}
