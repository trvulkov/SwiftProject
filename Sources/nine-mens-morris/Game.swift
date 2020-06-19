class Game {
    private var white = Pieces()
    private var black = Pieces()

    private let board = Board()
    private var phase = Phase.placing

    private var current = Color.white
}

extension Game: CustomStringConvertible {
    var description: String {
        return """
        white: \(white.free) free, \(white.placed) placed, at \(white.positions)
        black: \(black.free) free, \(black.placed) placed, at \(black.positions)
        \(board)
        """
    }
}


extension Game { // game actions
    func place() -> String {
        print("\(current) player, input coordinates to place piece at:")

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

    func move() -> String {
        print("\(current) player, input coordinates of position to move piece from, and position to move piece to:")

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

    func remove() {
        print("\(current) player formed a mill - input coordinates to remove opponent's piece from:")

        while true {
            if let position = readLine() {
                do {
                    var checkForMill = true
                    switch current { // if all of a player's pieces are in a mill, they can be removed without issue
                        case .white: checkForMill = !black.positions.allSatisfy{ board.inMill(color: .black, position: $0) }
                        case .black: checkForMill = !white.positions.allSatisfy{ board.inMill(color: .white, position: $0) }
                    }

                    try board.remove(color: current, from: position, checkForMill: checkForMill)

                    switch current {
                        case .white: black.losePiece(position)
                        case .black: white.losePiece(position)
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
    func canMove(_ color: Color) -> Bool {
        switch color {
            case .white: 
                return white.positions.allSatisfy{ board.canMove(color: .white, from: $0) }
            case .black: 
                return black.positions.allSatisfy{ board.canMove(color: .black, from: $0) }
        }        
    }

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
    func loop() {
        var finishedReading = false
        repeat {
            print("Who should move first? white/black")
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

        while phase == .placing || (phase == .moving && canPlay(.white) && canPlay(.black)) {
            print(self)

            var res: String
            switch phase {
                case .placing:
                    res = place()
                case .moving:
                    res = move()
            }

            if board.inMill(color: current, position: res) {
                print(self)
                remove()
            }

            current = current.other

            if white.free == 0 && black.free == 0 {
                phase = .moving
            }
        }

        print(self)
        if white.placed == 2 {
            print("Victory for black player - white player has less than 3 pieces!")
        } else if black.placed == 2 {
            print("Victory for white player - black player has less than 3 pieces!")
        } else if canMove(.white) == false && canMove(.black)  {
            print("Victory for black player - white player cannot move their pieces!")
        } else if canMove(.white) && canMove(.black) == false {
            print("Victory for white player - black player cannot move their pieces!")
        } else if canMove(.white) == false && canMove(.black) == false {
            print("Draw - neither player can move their pieces!")
        }
    }

}

