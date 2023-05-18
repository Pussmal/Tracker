import Foundation

enum ColorPageType: CaseIterable {
    case blue
    case red
    case three
    case foure
    
    var imageName: String {
        switch self {
        case .blue:
            return "BlueOnboardingBackground"
        case .red:
            return "RedOnboardingBackground"
        case .three:
            return "BlueOnboardingBackground"
        case .foure:
            return "RedOnboardingBackground"
        }
    }
    
    var infoText: String {
        switch self {
        case .blue:
            return "1"
        case .red:
            return "2"
        case .three:
            return "3"
        case .foure:
            return "4"
        }
    }
}
