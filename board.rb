#Board Class, this will handles board state, wins/losses/piece positions/check
class Board
  #Pieces, shorthand.
  WR = {type: :rook, color: :white}
  WP = {type: :pawn, color: :white}
  WB = {type: :bishop, color: :white}
  WN = {type: :knight, color: :white}#Horse
  WK = {type: :king, color: :white}
  WQ = {type: :queen, color: :white}

  EP = {type: :empty, color: :empty}

  BR = {type: :rook, color: :black}
  BP = {type: :pawn, color: :black}
  BB = {type: :bishop, color: :black}
  BN = {type: :knight, color: :black}#Horse
  BK = {type: :king, color: :black}
  BQ = {type: :queen, color: :black}

  DEFAULT_GRID = [
    [BR, BN, BB, BQ, BK, BB, BN, BR],
    [BP, BP, BP, BP, BP, BP, BP, BP],
    [EP, EP, EP, EP, EP, EP, EP, EP],
    [EP, EP, EP, EP, EP, EP, EP, EP],
    [EP, EP, EP, EP, EP, EP, EP, EP],
    [EP, EP, EP, EP, EP, EP, EP, EP],
    [WP, WP, WP, WP, WP, WP, WP, WP],
    [WR, WN, WB, WQ, WK, WB, WN, WR]
  ]
  attr_reader :grid

  def initialize
    @grid = DEFAULT_GRID.map do |row|
      row.map do |piece_info|
        Piece.generate(piece_info[:type], piece_info[:color])
      end
    end
  end

  def player_color(pos)
    grid[pos[0]][pos[1]].color
  end

end
