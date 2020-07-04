// stores information about the pieces of a player
class Pieces {
    var free: Int = 9   // how many pieces there are left to place
    var placed: Int = 0 // how many are currently on the board

    var positions: Set<String> = Set() // the positions of the pieces on the board
}

extension Pieces { // manipulating pieces
    // there functions are called by functions of the Game class, in order to reflect the changes to the pieces
    
    // called by Game.place()
    func place(_ position: String) {
        if free > 0 {
            free -= 1
            placed += 1

            positions.insert(position)
        }
    }

    // called by Game.remove()
    func remove(_ position: String) {
        if placed > 0 {
            placed -= 1

            positions.remove(position)
        }
    }

    // called by Game.move()
    func move(from: String, to: String) {
        positions.remove(from)
        positions.insert(to)
    }
}
