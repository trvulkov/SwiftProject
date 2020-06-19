enum PlacingError: Error {
    case invalidPosition
    case placeAtOccupied
}

enum MovingError: Error {
    case invalidMoveFrom
    case invalidMoveTo

    case moveFromWrongColor
    case moveToOccupied

    case notAdjacent
}

enum RemovingError: Error {
    case invalidPosition
    case removeFromEmpty
    case removeFromWrongColor
    case removeFromMill
}
