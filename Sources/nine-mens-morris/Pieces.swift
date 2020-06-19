class Pieces {
    var free: Int = 9
    var placed: Int = 0

    var positions: [String] = []
}

extension Pieces { // manipulating pieces
    func place(_ position: String) {
        if free > 0 {
            free -= 1
            placed += 1

            positions.append(position)
        }
    }

    func losePiece(_ position: String) {
        if placed > 0 {
            placed -= 1

            positions.removeAll(where: {$0 == position})
        }
    }
    
    func move(from: String, to: String) {
        positions.removeAll(where: {$0 == from})
        positions.append(to)
    }
}
