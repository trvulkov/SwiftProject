class Board {
    // the nodes are stored in a dictionary, with the keys being their coordinates on the board 
    let nodes: Dictionary<String, Node>

    init() { // initialize nodes with their adjacent nodes
        nodes = ["a7": Node(right: "d7", below: "a4"),      "d7": Node(left: "a7", right: "g7", below: "d6"),               "g7": Node(left: "d7", below: "g4"),

                 "b6": Node(right: "d6", below: "b4"),      "d6": Node(above: "d7", left: "b6", right: "f6", below: "d5"),  "f6": Node(left: "d6", below: "f4"),

                 "c5": Node(right: "d5", below: "c4"),      "d5": Node(above: "d6", left: "c5", right: "e5"),               "e5": Node(left: "d5", below: "e4"),

                 "a4": Node(above: "a7", right: "b4", below: "a1"),             "b4": Node(above: "b6", left: "a4", right: "c4", below: "b2"),  
                 "c4": Node(above: "c5", left: "b4", below: "c3"),              "e4": Node(above: "e5", right: "f4", below: "e3"),  
                 "f4": Node(above: "f6", left: "e4", right: "g4", below: "f2"), "g4": Node(above: "g7", left: "f4", below: "g1"),

                 "c3": Node(above: "c4", right: "d3"),      "d3": Node(left: "c3", right: "e3", below:"d2"),                "e3": Node(above: "e4", left: "d3"),

                 "b2": Node(above: "b4", right: "d2"),      "d2": Node(above: "d3", left: "b2", right: "f2", below: "d1"),  "f2": Node(above: "f4", left: "d2"),

                 "a1": Node(above: "a4", right: "d1"),      "d1": Node(above: "d2", left: "a1", right: "g1"),               "g1": Node(above: "g4", left: "d1"),]
    }
}

extension Board: CustomStringConvertible {
    var description: String {
        guard let a7 = nodes["a7"], let d7 = nodes["d7"], let g7 = nodes["g7"], let b6 = nodes["b6"], let d6 = nodes["d6"], let f6 = nodes["f6"], 
              let c5 = nodes["c5"], let d5 = nodes["d5"], let e5 = nodes["e5"], let a4 = nodes["a4"], let b4 = nodes["b4"], let c4 = nodes["c4"], 
              let e4 = nodes["e4"], let f4 = nodes["f4"], let g4 = nodes["g4"], let c3 = nodes["c3"], let d3 = nodes["d3"], let e3 = nodes["e3"], 
              let b2 = nodes["b2"], let d2 = nodes["d2"], let f2 = nodes["f2"], let a1 = nodes["a1"], let d1 = nodes["d1"], let g1 = nodes["g1"] 
        else {
            return("ERROR: Cannot print node!")
        }

        return """
        7 \(a7)-----------\(d7)-----------\(g7)
          |           |           |
        6 |   \(b6)-------\(d6)-------\(f6)   |
          |   |       |       |   |
        5 |   |   \(c5)---\(d5)---\(e5)   |   |
          |   |   |       |   |   |
        4 \(a4)---\(b4)---\(c4)       \(e4)---\(f4)---\(g4)
          |   |   |       |   |   |
        3 |   |   \(c3)---\(d3)---\(e3)   |   |
          |   |       |       |   |
        2 |   \(b2)-------\(d2)-------\(f2)   |
          |           |           |
        1 \(a1)-----------\(d1)-----------\(g1)
          a   b   c   d   e   f   g
        """
    }
}

extension Board { // game logic - manipulating pieces
    // Places a piece of the given color, at the given position
    // (if the position isn't actually on the board, or it is but is already occupied - an exception is thrown).
    func place(color: Color, at position: String) throws {
        guard let node = nodes[position] else {
            throw PlacingError.invalidPosition
        }
        guard node.state == .empty else {
            throw PlacingError.placeAtOccupied
        }

        node.state = .occupied(by: color)
    }

    // Moves a piece of a given color between two positions
    // (if either of the positions isn't on the board, the first one isn't occupied by a piece of the given color, or the second one isn't empty - an exception is thrown).
    // The boolean argument determines whether the piece can "fly" - if not, a check is made for adjacency between the positions (and an exception is thrown if it fails).
    func move(color: Color, from: String, to: String, flying: Bool = false) throws {
        guard let start = nodes[from] else {
            throw MovingError.invalidMoveFrom
        }
        guard let end = nodes[to] else {
            throw MovingError.invalidMoveTo
        }
        guard start.state == .occupied(by: color) else {
            throw MovingError.moveFromWrongColor
        }
        guard end.state == .empty else {
            throw MovingError.moveToOccupied
        }

        if flying == false {
            guard start.adjacent.contains(to) else {
                throw MovingError.notAdjacent
            }
        }

        start.state = .empty
        end.state = .occupied(by: color)
    }

    // Removes a piece of the color opposite to the given color (the player of a certain color removes pieces of the opposite color), from the given position
    // (if the position isn't actually on the board, or there isn't a piece of the given color on it, an exception is thrown).
    // If checkForMill is true, and an attempt is made to remove a piece that is currently in a mill, an exception is thrown.
    func remove(color: Color, from position: String, checkForMill: Bool) throws {
        guard let node = nodes[position] else {
            throw RemovingError.invalidPosition
        }
        guard node.state != .empty else {
            throw RemovingError.removeFromEmpty
        }
        guard node.state == .occupied(by: color.other) else {
            throw RemovingError.removeFromWrongColor
        }

        if checkForMill {
            guard inMill(color: color.other, position: position) == false else {
                throw RemovingError.removeFromMill
            }
        }
        
        node.state = .empty
    }

    // Checks if a piece of the given color can move from the given position (i.e. if there are any unoccupied positions adjacent to it).
    func canMove(color: Color, from position: String) -> Bool {
        if let node = nodes[position], node.state == .occupied(by: color) {
            for neighbour in node.adjacent {
                if let neighbourNode = nodes[neighbour], neighbourNode.state == .empty {
                    return true
                }
            }
        }

        return false
    }
}

extension Board { // game logic - mills
    // Checks if a piece is in a mill, by calling the middleOfMill() and edgeOfMill() functions.
    func inMill(color: Color, position: String) -> Bool {
        if let node = nodes[position] {
            return middleOfMill(color: color, node: node) || edgeOfMill(color: color, node: node)
        }

        return false
    }

    // Checks if a piece is in the middle of mill, i.e. if it forms a mill with two of it's neighbours (either the ones to the left and to the right, or above and below).
    // Only called by the inMill() function.
    private func middleOfMill(color: Color, node: Node) -> Bool {
        // check for horizontal mill
        if let left = node.left, let leftNode = nodes[left], 
           let right = node.right, let rightNode = nodes[right], 
           leftNode.state == .occupied(by: color) && rightNode.state == .occupied(by: color) {
            return true
        } 
        
        // check for vertical mill
        if let above = node.above, let aboveNode = nodes[above], 
           let below = node.below, let belowNode = nodes[below],
           aboveNode.state == .occupied(by: color) && belowNode.state == .occupied(by: color) {
            return true
        }

        return false
    }

    // Checks if a piece is the edge of mill, i.e. if it forms a mill with a neighbour and that neighbour's neighbour in one of the four directions.
    // Only called by the inMill() function.
    private func edgeOfMill(color: Color, node: Node) -> Bool {
        checkDirection(color: color, direction: .above, node: node) || checkDirection(color: color, direction: .left, node: node) ||
        checkDirection(color: color, direction: .right, node: node) || checkDirection(color: color, direction: .below, node: node)
    }

    // Checks if a piece forms a mill with a neighbour and that neighbour's neighbour in a given direction.
    // Only called by the edgeOfMill() function.
    private func checkDirection(color: Color, direction: Direction, node: Node, found: Int = 1) -> Bool {
        if found == 3 {
            return true
        }

        if let neighbour = node.getNeighbour(direction: direction), let neighbourNode = nodes[neighbour] {
            return neighbourNode.state == .occupied(by: color) && checkDirection(color: color, direction: direction, node: neighbourNode, found: found + 1)
        }

        return false
    }
}

