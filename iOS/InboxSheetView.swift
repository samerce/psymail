import SwiftUI

private enum Grouping: String, CaseIterable, Identifiable {
    case emailAddress = "address"
//    case contactCard = "contact"
    case subject
    case time

    var id: String { self.rawValue }
}

private let ToolbarHeight: CGFloat = 18
private let FirstExpandedNotch: CGFloat = 0.5

struct InboxSheetView: View {
  @State private var selectedGrouping = Grouping.emailAddress
  @State private var hiddenViewOpacity = 0.0
  @Binding var bundle: String
  @State private var translationProgress: Double = 0
  
  private var bottomSpace: CGFloat {
    CGFloat.maximum(6, 42 - (CGFloat(translationProgress) / FirstExpandedNotch) * 42)
  }
  private var dividerHeight: CGFloat {
    CGFloat.maximum(0, DividerHeight - (CGFloat(translationProgress) / FirstExpandedNotch) * DividerHeight)
  }
  private var hiddenSectionOpacity: CGFloat {
    translationProgress > 0 ? translationProgress + 0.48 : 0
  }
  
  // MARK: - View
  
  var body: some View {
    VStack(spacing: 0) {
      Text("psymail")
        .font(.system(size: 27, weight: .black))
        .padding(.top, 12)
        .padding(.bottom, 18)
      
      BundleTabBarView(selection: $bundle, translationProgress: $translationProgress)

      Divider()
        .frame(height: dividerHeight)
        .padding(.horizontal, 9)
        .padding(.bottom, 6)
      
      Toolbar
        .padding(.bottom, bottomSpace)

      ScrollView {
        MailboxSection
          .padding(.bottom, 18)
        AppSection
      }
      .padding(0)
    }
  }
  
  private let DividerHeight: CGFloat = 9
  private let allMailboxesIconSize: CGFloat = 25
  private let composeIconSize: CGFloat = 25
  
  private var Toolbar: some View {
    let height = CGFloat.maximum(0, ToolbarHeight - (CGFloat(translationProgress) / FirstExpandedNotch) * ToolbarHeight)
    let opacity = CGFloat.maximum(0, 1 - (CGFloat(translationProgress) / FirstExpandedNotch))
    return VStack(alignment: .center, spacing: 0) {
      HStack(spacing: 0) {
          Button(action: loginWithGoogle) {
            ZStack {
              Image(systemName: "line.3.horizontal.decrease.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.psyAccent)
                .frame(maxWidth: allMailboxesIconSize, maxHeight: height)
                .font(.system(size: allMailboxesIconSize, weight: .light))
            }.frame(width: 54, height: 50, alignment: .leading)
          }.frame(width: 54, height: 50, alignment: .leading)
        
        Text("updated just now")
          .font(.system(size: 14, weight: .light))
          .foregroundColor(.secondary)
          .frame(maxWidth: .infinity, maxHeight: height)
          .multilineTextAlignment(.center)
          .clipped()
        
        Button(action: {}) {
          ZStack {
            Image(systemName: "square.and.pencil")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .foregroundColor(.psyAccent)
              .frame(maxWidth: composeIconSize, maxHeight: height)
              .font(.system(size: composeIconSize, weight: .light))
          }.frame(width: 54, height: 50, alignment: .trailing)
        }.frame(width: 54, height: 50, alignment: .leading)
      }
      .frame(height: height)
    }
    .padding(.horizontal, 24)
    .opacity(Double(opacity))
    .clipped()
  }
  
  private var MailboxSection: some View {
    VStack(spacing: 18) {
      HStack(spacing: 0) {
        Text("MAILBOXES")
          .font(.system(size: 14, weight: .light))
          .foregroundColor(Color(.gray))
        
        Spacer()
        
        Button(action: {}) {
          ZStack {
            Image(systemName: "gear")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .foregroundColor(.psyAccent)
              .font(.system(size: 16, weight: .light))
          }
          .frame(width: 20, alignment: .trailing)
        }
      }
      
      Mailbox("samerce@gmail.com")
      Mailbox("bubbles@expressyouryes.org")
      Mailbox("petals@expressyouryes.org")
    }
    .padding(.horizontal, 18)
    .clipped()
  }
  
  private var AppSection: some View {
    VStack(alignment: .leading, spacing: 18) {
      Text("APP")
        .font(.system(size: 14, weight: .light))
        .foregroundColor(Color(.gray))
      
      Mailbox("Settings")
      Mailbox("About")
      Mailbox("Feedback")
      Mailbox("Support Us")
    }
    .padding(.horizontal, 18)
  }
  
  private func Mailbox(_ name: String) -> some View {
    Text(name)
      .padding()
      .overlay(RoundedRectangle(cornerRadius: 12.0).stroke(.gray))
      .frame(maxWidth: .infinity, alignment: .leading)
  }
  
  private func header(_ text: String) -> some View {
    Text(text)
      .font(.system(size: 12, weight: .light))
      .foregroundColor(Color(UIColor.systemGray))
      .frame(maxWidth: .infinity, alignment: .leading)
  }
  
  private func loginWithGoogle() {
    AccountController.shared.signIn()
  }
  
}

struct InboxDrawerView_Previews: PreviewProvider {
  @State static var progress = 0.0
  @State static var perspective = "latest"
  static var previews: some View {
    InboxSheetView(bundle: $perspective)
  }
}