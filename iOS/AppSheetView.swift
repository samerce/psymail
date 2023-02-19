import SwiftUI

struct AppSheetView: View {
  
  @Binding var view: String
  @Binding var bundle: String
  
  var body: some View {
    ZStack {
      OverlayBackgroundView()
      Sheet
        .interactiveDismissDisabled()
        .presentationDetents(
          undimmed: [
            .height(appSheetDetents.min),
            .height(appSheetDetents.mid),
            .height(appSheetDetents.max)
          ]
        )
    }
    .ignoresSafeArea()
    .introspectViewController { vc in
      vc.view.backgroundColor = .clear
    }
  }
  
  private var Sheet: some View {
    Group {
      if view == "inbox" {
        InboxSheetView(bundle: $bundle)
      } else {
        EmailToolsSheetView()
      }
    }
  }
  
}
