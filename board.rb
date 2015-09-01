#Board Class, this will handles board state, wins/losses/piece positions/check
class Board
  #Pieces, shorthand.
  WR = {type: :rook, color: :white}
  WP = {type: :pawn, color: :white}
  WB = {type: :bishop, color: :white}
  WN = {type: :knight, color: :white}#Horse
  WK = {type: :king, color: :white}
  WQ = {type: :queen, color: :white}

  EP = {type: :empty, color: :default}

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
    @grid = DEFAULT_GRID.map.with_index do |row, row_idx|
      row.map.with_index do |piece_info, col_idx|
        Piece.generate(piece_info[:type], piece_info[:color], [row_idx, col_idx])
      end
    end
  end

  #Returns color of piece at board
  def player_color(pos)
    grid[pos[0]][pos[1]].color
  end

  def move(from, to)
    if valid_move?(from, to)
      from_row = from[0]
      from_col = from[1]
      to_row = to[0]
      to_col = to[1]
      piece = grid[from_row][from_col]

      piece.pos = to
      piece.moved = true
      grid[to_row][to_col] = piece
      grid[from_row][from_col] = EmptyPiece.new(:default, from)
    end
  end

  def valid_move?(from, to)
    from_row = from[0]
    from_col = from[1]
    to_row = to[0]
    to_col = to[1]
    grid[from_row][from_col].valid_move?(to)
  end

end
