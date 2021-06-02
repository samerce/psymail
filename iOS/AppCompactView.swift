import SwiftUI

struct AppCompactView: View {
  
  var body: some View {
    ZStack(alignment: .topTrailing) {
      EmailListView()
      EmailDetailView()
    }
    .ignoresSafeArea()
  }
  
}

struct AppCompactView_Previews: PreviewProvider {
  static var previews: some View {
    AppCompactView()
      .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
