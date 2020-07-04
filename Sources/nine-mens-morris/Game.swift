class Game {
    private var white = Pieces() // stores information about the white player's pieces
    private var black = Pieces() // stores information about the black player's pieces

    private let board = Board()
    private var phase = Phase.placing

    private var current = Color.white // the player who should play on the current turn. Changes to the other color every turn
}

extension Game: CustomStringConvertible {
    // allows the printing of information about the game at it's current stage - information about the players' pieces, and the state of the board itself
    var description: String {
        return """
        white: \(white.free) unplaced, \(white.placed) placed, at \(white.positions)
        black: \(black.free) unplaced, \(black.placed) placed, at \(black.positions)
        \(board)
        """
    }
}


extension Game { // game actions
    // Requests the coordinates of a single position, reads them from the standard input and calls Board.place() with the color of the current player and said position.
    // Catches that function's exceptions and prints an approriate message if any one is caught.
    // If the placement is successful, calls the Pieces.place() function of the current player and returns the position.
    func place() -> String {
        print("\(current) player, PLACE your piece:")

        while true {
            if let position = readLine() {
                do {
                    try board.place(color: current, at: position)

                    switch current {
                        case .white: white.place(position)
                        case .black: black.place(position)
                    }

                    return position
                } catch PlacingError.invalidPosition {
                    print("ERROR: Invalid position!")
                } catch PlacingError.placeAtOccupied {
                    print("ERROR: Position is already occupied!")
                } catch {
                    print("ERROR: Unknown error!")
                }
            } else {
                print("ERROR: Invalid input!")
            }            
        }
    }

    // Requests the coordinates of two positions, reads a single line from the standard input and checks if it is of the appropriate length.
    // If yes, also checks whether the current player can "fly" their pieces and calls Board.move() with the color of the current player, both positions,
    // and an appropriate boolean value for the "flying".
    // Catches that function's exceptions and prints an approriate message if any one is caught.
    // If the movement is successful, calls the Pieces.move() function of the current player and returns the second position.
    func move() -> String {
        print("\(current) player, MOVE your piece:")

        while true {
            if let positions = readLine() {
                guard positions.count == 4 else {
                    print("ERROR: Invalid input!")
                    continue
                }
                let start = String(positions.prefix(2))
                let end = String(positions.suffix(2))

                do {
                    var flying: Bool
                    switch current {
                        case .white: flying = white.placed <= 3
                        case .black: flying = black.placed <= 3
                    }

                    try board.move(color: current, from: start, to: end, flying: flying)

                    switch current {
                        case .white: white.move(from: start, to: end)
                        case .black: black.move(from: start, to: end)
                    }

                    return end
                } catch MovingError.invalidMoveFrom {
                    print("ERROR: Invalid first position!")
                } catch MovingError.invalidMoveTo {
                    print("ERROR: Invalid second position!")
                } catch MovingError.moveFromWrongColor {
                    print("ERROR: The starting position isn't occupied by you!")
                } catch MovingError.moveToOccupied {
                    print("ERROR: The target position is already occupied!")
                } catch MovingError.notAdjacent {
                    print("ERROR: Can't move from \(start) to \(end)!")
                } catch {
                    print("ERROR: Unknown error!")
                }
            } else {
                print("ERROR: Invalid input!")
            }
        }
    }

    // Requests the coordinates of a single position, reads them from the standard input and calls Board.remove() 
    // with the color of the current player, the position and an appropriate boolean value determining whether pieces can be removed from mills or not.
    // Catches that function's exceptions and prints an approriate message if any one is caught.
    // If the removal is successful, calls the Pieces.remove() function of the other player.
    func remove() {
        print("\(current) player - REMOVE opponent's piece:")

        while true {
            if let position = readLine() {
                do {
                    var checkForMill: Bool
                    // If all of a player's pieces are in a mill, they can be removed without issue, so checkForMill is false. 
                    // Otherwise, only pieces not in a mill can be removed, so checkForMill is true.
                    switch current { 
                        case .white: checkForMill = !black.positions.allSatisfy{ board.inMill(color: .black, position: $0) }
                        case .black: checkForMill = !white.positions.allSatisfy{ board.inMill(color: .white, position: $0) }
                    }

                    try board.remove(color: current, from: position, checkForMill: checkForMill)

                    switch current {
                        case .white: black.remove(position)
                        case .black: white.remove(position)
                    }

                    return
                } catch RemovingError.invalidPosition {
                    print("ERROR: Invalid position!")
                } catch RemovingError.removeFromEmpty {
                    print("ERROR: Cannot remove from empty position!")
                } catch RemovingError.removeFromWrongColor {
                    print("ERROR: Cannot remove your own pieces!")
                } catch RemovingError.removeFromMill {
                    print("ERROR: Cannot remove from opponent's mills!")   
                } catch {
                    print("ERROR: Unknown error!")
                }
            } else {
                print("ERROR: Invalid input!")
            }            
        }
    }

}

extension Game { // checking if the game can continue
    // checks if the player of the given color can move at least one of their pieces
    func canMove(_ color: Color) -> Bool {
        switch color {
            case .white: 
                return white.positions.contains{ board.canMove(color: .white, from: $0) }
            case .black: 
                return black.positions.contains{ board.canMove(color: .black, from: $0) }
        }        
    }

    // checks if the player of the given color can continue playing the game, i.e. if they have enough pieces and can move at least one
    func canPlay(_ color: Color) -> Bool {
        switch color {
            case .white: 
                return white.placed >= 3 && canMove(.white)
            case .black: 
                return black.placed >= 3 && canMove(.black)
        }
    }

}

extension Game { // game loop
    // Requests information about which player should move first.
    // After that, loops while the game can continue (both players have enough pieces and can move at least one of them), with each iteration
    // calling either place() or move() depending on the phase of the game. If a mill is formed, calls remove().
    // After the looping condition becomes false, prints an appropriate message for the end of the game, 
    // describing who won and by what cause in the case of victory, or that the outcome is a draw.
    func loop() {
        var finishedReading = false
        repeat {
            print("Who should move first? (white or black)")
            if let line = readLine() {
                switch line {
                    case "white": 
                        current = .white
                        finishedReading = true
                    case "black": 
                        current = .black
                        finishedReading = true
                    default: 
                        print("ERROR: Invalid input!")
                }
            }
        } while finishedReading == false

        print("""
        INSTRUCTIONS:
        At the start of every turn, the board is printed, with the occupied positions marked 
        by ○ for white pieces and ● for black pieces.

        Depending on the phase of the game, the players are asked to input coordinates of positions:
        - during the placement phase, input the coordinates of a single position (e.g. "a7") to place a piece there. 
        The position should be unoccupied.
        - during the movement phase, input the coordinates of two positions (e.g. "a7a4") to move a piece from the first to the second.
        The first position should have a piece of your color, and the second should be adjacent to it and unoccupied. 
        If you have only 3 pieces left however, you can move to non-adjacent positions.

        If a mill is formed at any point, a message will be printed and you will need to input the coordinates of a single position,
        from which to remove a piece belonging to your opponent.

        In the case of invalid input (positions that don't exist, placing on already occupied positions, moving your opponent's pieces, etc.)
        an appropriate error message is printed and the turn is repeated (until correct input is given).
        """)

        while phase == .placing || (phase == .moving && canPlay(.white) && canPlay(.black)) {
            print(self)

            var position: String
            switch phase {
                case .placing:
                    position = place()
                case .moving:
                    position = move()
            }

            if board.inMill(color: current, position: position) {
                print(self)
                print("\(current) player FORMED A MILL!")

                remove()
            }

            // change player for next turn
            current = current.other

            if white.free == 0 && black.free == 0 {
                phase = .moving
            }
        }

        print(self)
        if white.placed == 2 {
            print("VICTORY for BLACK player - white player has less than 3 pieces!")
        } else if black.placed == 2 {
            print("VICTORY for WHITE player - black player has less than 3 pieces!")
        } else if canMove(.white) == false && canMove(.black)  {
            print("VICTORY for BLACK player - white player cannot move their pieces!")
        } else if canMove(.white) && canMove(.black) == false {
            print("VICTORY for WHITE player - black player cannot move their pieces!")
        } else if canMove(.white) == false && canMove(.black) == false {
            print("DRAW - neither player can move their pieces!")
        }
    }

}

