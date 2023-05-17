import Foundation

enum ColorPageType: CaseIterable {
    case blue
    case red
    
    var imageName: String {
        switch self {
        case .blue:
            return "BlueOnboardingBackground"
        case .red:
            return "RedOnboardingBackground"
        }
    }
    
    var infoText: String {
        switch self {
        case .blue:
            return "Отслеживайте только то, что хотите"
        case .red:
            return "Даже если это не литры воды и йога"
        }
    }
}
