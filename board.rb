#Board Class, this will handles board state, wins/losses/piece positions/check

=begin #notes
Check/Checkmate/Stalemate conditions checker

=end
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
  #

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

  DIAGONAL_STEPS = {
    ur: {row: -1, col:  1}, #{:row => -1, :col => 1} #same.
    dr: {row:  1, col:  1},
    ul: {row: -1, col: -1},
    dl: {row:  1, col: -1}
  }

  LATERAL_STEPS = {
    uu: {row: -1, col:  0},
    dd: {row:  1, col:  0},
    rr: {row:  0, col:  1},
    ll: {row:  0, col: -1}
  }

  KNIGHT_STEPS = {
    uur: {row: -2, col:  1},
    uul: {row: -2, col: -1},
    urr: {row: -1, col:  2},
    ull: {row: -1, col: -2},
    ddr: {row:  2, col:  1},
    ddl: {row:  2, col: -1},
    drr: {row:  1, col:  2},
    dll: {row:  1, col: -2}
  }


  attr_reader :grid

  def initialize
    @grid = DEFAULT_GRID.map.with_index do |row, row_idx|
      row.map.with_index do |piece_info, col_idx|
        Piece.generate(piece_info[:type], piece_info[:color],
        {row: row_idx, col: col_idx}, self)
      end
    end
  end

  #Returns color of piece at board
  def player_color(pos)
    grid[pos[:row]][pos[:col]].color
  end

  def Board.move_hash(pos, color)
    {pos: pos.dup, color: color}
  end

  def [](pos)
    grid[pos[:row]][pos[:col]]
  end

  def hypothetical_check(start_pos = [nil, nil], end_pos = [nil, nil])
    false
  end

  def occupied?(pos)
    !self[pos].empty?
  end

  def on_board?(pos)
    pos[:row].between?(0,7) && pos[:col].between?(0, 7)
  end

  private
  def moves(pos, steps, max_travel=8)#ugly code.
    moves = []
    steps.each do |_, offsets|
      move_pos = pos.dup
      while on_board?(move_pos)
        moves << Board.move_hash(move_pos, self[move_pos].color)
        break if occupied?(move_pos) unless move_pos == pos #fucker.

        move_pos[:row] += offsets[:row]; move_pos[:col] += offsets[:col]
        break if (move_pos[:row] - pos[:row]).abs > max_travel
        break if (move_pos[:col] - pos[:col]).abs > max_travel
      end
    end
    moves.delete_if {|el| el[:pos] == pos}#don't inlcude starting_position
    moves
  end

  public
  def diagonal_moves(pos, max_travel=8)
    moves(pos, DIAGONAL_STEPS, max_travel)
  end

  def lateral_moves(pos, max_travel)
    moves(pos, LATERAL_STEPS, max_travel)
  end

  def knight_moves(pos)
    moves(pos, KNIGHT_STEPS)
  end

  def pawn_moves(pos)
    #lol, this will be fun!
  end

  def move(from, to)
    if valid_move?(from, to)
      piece = grid[from[:row]][from[:col]]
      piece.pos = to
      piece.moved = true

      grid[to[:row]][to[:col]] = piece#Eventually write capture method for if piece exists at to.
      grid[from[:row]][from[:col]] = EmptyPiece.new(:default, from, self)
    end
  end

  def valid_move?(from, to) #delete this eventually. Working on new methods.
    from_row, from_col = from[:row], from[:col]
    to_row, to_col = to[:row], to[:col]
    grid[from_row][from_col].valid_move?(to)
  end

end
