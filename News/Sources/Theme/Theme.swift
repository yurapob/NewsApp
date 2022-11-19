import UIKit

enum Theme { }

extension Theme {
    enum Colors {
        
        static let white: UIColor = .init(hexString: "#FFFFFF")
        static let black: UIColor = .init(hexString: "#000000")
        static let navigationWhite: UIColor = .init(hexString: "#FEFEFE")
        static let separatorGray: UIColor = .init(hexString: "#DEDEDE")
        static let textGray: UIColor = .init(hexString: "#8C8C8C")
        static let textLightGray: UIColor = .init(hexString: "#ADADAD")
    }
}

private extension UIFont.Weight {
    var neutonFontName: String? {
        switch self {
        case .light:
            return "Neuton-Light"
        case .bold:
            return "Neuton-Bold"
        default:
            return nil
        }
    }
}

extension Theme {
    enum Fonts {

        private static func font(for weight: UIFont.Weight, size: CGFloat = 17.0) -> UIFont {
            guard let name = weight.neutonFontName,
                let font = UIFont(name: name, size: size)
                else {
                    return UIFont.systemFont(ofSize: size, weight: weight)
            }
            return font
        }

        static let neutonLight: UIFont = font(for: .light)
        static let neutonBold: UIFont = font(for: .bold)
    }
}
