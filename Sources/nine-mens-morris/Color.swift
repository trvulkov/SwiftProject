enum Color: String {
    case white
    case black

    var other: Color {
        switch self {
            case .white: return .black
            case .black: return .white
        }
    }
}
