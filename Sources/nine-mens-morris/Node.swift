class Node {
    var state: State

    // neighbours
    let left:  String?
    let right: String?
    let above: String?
    let below: String?

    init(above: String? = nil, left: String? = nil, right: String? = nil, below: String? = nil) {
        state = .empty

        self.above = above
        self.left = left
        self.right = right
        self.below = below
    }

    var adjacent: [String] {
        return [above, left, right, below].compactMap{ $0 }
    }
}

extension Node: CustomStringConvertible {
    var description: String {
        switch state {
            case .empty:                return "·"
            case .occupied(by: .white): return "○"
            case .occupied(by: .black): return "●"
        }
    }
}


enum Direction {
    case above
    case left
    case right
    case below
}

extension Node {
    func getNeighbour(direction: Direction) -> String? {
        switch direction {
            case .above: return above
            case .left: return left
            case .right: return right
            case .below: return below
        }
    }
}

