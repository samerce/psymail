import SwiftUI


private let LabelHeight = 18.0
private let IconSize = 22.0


struct TabBarItem: View {
  let iconName: String
  let label: String
  var selected: Bool
  var collapsible: Bool
  
  @ObservedObject var sheetCtrl = AppSheetController.shared
  
  var percentToMid: CGFloat { sheetCtrl.percentToMid }
  var labelHeight: CGFloat {
    LabelHeight * percentToMid
  }
  var labelOpacity: Double {
    collapsible ? 1 : Double(percentToMid)
  }
  var fgColor: Color {
    selected ? .psyAccent : Color(.secondaryLabel)
  }
  
  var body: some View {
    VStack(alignment: .center) {
      Image(systemName: iconName)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: IconSize, height: IconSize)
        .font(.system(size: IconSize, weight: .light))
      
      Text(label)
        .font(.system(size: 11, weight: .light))
        .frame(height: labelHeight)
        .opacity(labelOpacity)
    }
    .frame(maxWidth: .infinity)
    .foregroundColor(fgColor)
    .contentShape(Rectangle())
  }
  
}
