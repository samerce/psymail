import SwiftUI
import CoreData
import Postal
import UIKit
import DynamicOverlay

enum Notch: CaseIterable, Equatable {
    case min, mid, max
}

let tabs = ["DMs", "events", "digests", "commerce", "society", "marketing", "news", "notifications"]

struct AppCompactView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @EnvironmentObject private var model: MailModel
  
  @State var notch: Notch = .min
  @State var isEditing = false
  @State var translationProgress = 0.0
  @State var selectedTab = 2
  @State var selectedRow:UInt? = 0
  
  var body: some View {
    NavigationView {
      ZStack {
        ScrollView {
          LazyVStack {
            let messages = model.sortedEmails[tabs[selectedTab]] ?? []
            ForEach(messages, id: \.uid) { msg in
              let row = getListRow(msg)
              if (Double(msg.uid).truncatingRemainder(dividingBy: 3.5)) == 0 {
                row
                  .overlay(RainbowGlowBorder().opacity(0.98))
                  .background(VisualEffectBlur(blurStyle: .prominent))
                  .cornerRadius(12)
              } else {
                row
              }
            }
            .onDelete { _ in print("deleted") }
          }
//          .animation(.interactiveSpring())
          .padding(.horizontal, 6)
          
          Spacer().frame(height: 138)
        }
        .padding(.horizontal, -2)
      
        backdropView.opacity(translationProgress)
      }
      .dynamicOverlay(overlay)
      .dynamicOverlayBehavior(behavior)
      .ignoresSafeArea()
      .navigationBarTitle(tabs[selectedTab])
      .navigationBarItems(
        leading:
//          rainbowGradientHorizontal.mask(
            Image(systemName: "mail")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .font(.system(size: 27, weight: .light, design: .default))
              .frame(width: 27, height: 27)
          .foregroundColor(.pink),
//          ).frame(width: 27, height: 27),
        trailing:
//          rainbowGradientHorizontal.mask(
            EditButton()
              .font(.system(size: 17, weight: .regular, design: .default))
          .foregroundColor(.pink)
//          ).frame(width: 32, height: 36)
      )
    }
  }
  
  let oneDay = 24.0 * 3600
  let twoDays = 48.0 * 3600
  let oneWeek = 24.0 * 7 * 3600
  private func getListRow(_ msg: FetchResult) -> some View {
    let sender = msg.header?.from[0].displayName ?? "Unknown"
    let subject = msg.header?.subject ?? "---"
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h:mm a"
    let timeSinceMessage = msg.internalDate?.distance(to: Date()) ?? Double.infinity
    if  timeSinceMessage > oneDay && timeSinceMessage < twoDays   {
      dateFormatter.doesRelativeDateFormatting = true
      dateFormatter.dateStyle = .short
      dateFormatter.timeStyle = .short
    } else if timeSinceMessage > twoDays && timeSinceMessage < oneWeek {
      dateFormatter.dateFormat = "E h:mm a"
    } else if timeSinceMessage > oneWeek {
      dateFormatter.dateFormat = "M/d/yy"
    }
    let date = (msg.internalDate != nil) ? dateFormatter.string(from: msg.internalDate!) : ""
    return ZStack {
      VStack(alignment: .leading, spacing: 2) {
        HStack(alignment: .lastTextBaseline) {
          Text(sender)
            .font(.system(size: 15, weight: .bold, design: .default))
            .lineLimit(1)
          Spacer()
          Text(date)
            .font(.system(size: 12, weight: .light, design: .default))
            .foregroundColor(Color.secondary)
//          rainbowGradientVertical.mask(
            Image(systemName: "chevron.right")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .foregroundColor(.gray)
              .frame(width: 12, height: 12)
              .offset(x: 0, y: 1)
//          ).frame(width: 12, height: 12)
        }
        Text(subject)
          .font(.system(size: 15, weight: .light, design: .default))
          .lineLimit(2)
      }
      .foregroundColor(Color.primary)
      .padding(.horizontal, 6)
      .padding(.vertical, 12)
      
      NavigationLink(destination: MessageView(msg), tag: msg.uid, selection: $selectedRow) {
        EmptyView()
      }
    }
    .listRowInsets(EdgeInsets())
    .padding(.horizontal, 6)
    .contentShape(Rectangle())
    .onTapGesture {
      selectedRow = msg.uid
    }
  }
  
  private func getRowBackground(_ msg: FetchResult) -> some View {
    var background: AnyView
    if (Double(msg.uid).truncatingRemainder(dividingBy: 3.5)) == 0  {
      background = AnyView(Rectangle())
    } else {
      let rect = RainbowGlowBorder()
      background = AnyView(rect)
    }
    return background
  }
  
  private var backdropView: some View {
    Color.black.opacity(0.3)
  }
  
  private var overlay: some View {
    InboxDrawerView(selectedTab: $selectedTab, translationProgress: $translationProgress) { event in
      switch event {
      case .didTapTab:
        isEditing = true
        withAnimation { notch = .max }
      }
    }
    .onChange(of: selectedTab) { _ in
      withAnimation {
        notch = .min
      }
    }
    .ignoresSafeArea()
  }
  
  private var behavior: some DynamicOverlayBehavior {
    MagneticNotchOverlayBehavior<Notch> { notch in
      switch notch {
      case .max:
        return .fractional(0.77)
      case .mid:
        return .fractional(0.54)
      case .min:
        return .fractional(0.12)
      }
    }
    .disable(.min, isEditing)
    .notchChange($notch)
    .onTranslation { translation in
      translationProgress = translation.progress
    }
  }
  
  private func showAbout() {
    
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
}

private let itemFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .short
  formatter.timeStyle = .medium
  return formatter
}()

struct AppCompactView_Previews: PreviewProvider {
  static var previews: some View {
    let model = MailModel()
    model.signIn()
    return AppCompactView()
      .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
      .environmentObject(model)
  }
}
