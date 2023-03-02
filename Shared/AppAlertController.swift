import Foundation

class AppAlertController: ObservableObject {
  static let shared = AppAlertController()
  
  @Published var message: String?
  @Published var icon: String?
  @Published var visible: Bool = false
  @Published var action: (() -> Void)?
  @Published var actionLabel: String?
  @Published var duration: TimeInterval = 0
  @Published var delay: TimeInterval = 0
  
  // MARK: -
  
  private init() {
    
  }
  
  func show(
    message: String,
    icon: String,
    duration: TimeInterval = 4,
    delay: TimeInterval = 0,
    action: (() -> Void)? = nil,
    actionLabel: String? = nil
  ) {
    self.message = message
    self.icon = icon
    self.action = action
    self.actionLabel = actionLabel
    self.duration = duration
    self.delay = delay
    self.visible = true
  }
  
  func hide() {
    visible = false
    message = nil
    icon = nil
    action = nil
    actionLabel = nil
    duration = 0
  }
  
}
