// The phase of the game - placing or moving pieces. 
// The third phase ("flying") isn't present here, as it doesn't always affect both players - 
// it's instead implemented by checking for the amount of pieces of a specific player when they input a move command
enum Phase {
    case placing
    case moving
}
