// errors to be thrown when placing a piece
enum PlacingError: Error {
    case invalidPosition
    case placeAtOccupied
}

// errors to be thrown when moving a piece between positions
enum MovingError: Error {
    case invalidMoveFrom
    case invalidMoveTo

    case moveFromWrongColor
    case moveToOccupied

    case notAdjacent
}

// errors to be thrown when removing a piece
enum RemovingError: Error {
    case invalidPosition
    case removeFromEmpty
    case removeFromWrongColor
    case removeFromMill
}
