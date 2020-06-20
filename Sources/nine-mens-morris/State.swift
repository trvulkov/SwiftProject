// the state of a position on the board
enum State: Equatable {
    case empty
    case occupied(by: Color)
}
