#Board Class, this will handles board state, wins/losses/piece positions/check

=begin #notes
Check/Checkmate/Stalemate conditions checker

=end
class Board
  #Pieces, shorthand.
    WR = {klass: Rook, color: :white}
    WP = {klass: Pawn, color: :white}
    WB = {klass: Bishop, color: :white}
    WN = {klass: Knight, color: :white}#Horse
    WK = {klass: King, color: :white}
    WQ = {klass: Queen, color: :white}

    EP = {klass: EmptyPiece, color: :default}

    BR = {klass: Rook, color: :black}
    BP = {klass: Pawn, color: :black}
    BB = {klass: Bishop, color: :black}
    BN = {klass: Knight, color: :black}#Horse
    BK = {klass: King, color: :black}
    BQ = {klass: Queen, color: :black}
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

  def initialize(grid = nil)
    if grid == nil
      @grid = DEFAULT_GRID.map.with_index do |row, row_idx|
        row.map.with_index do |piece_info, col_idx|
          klass = piece_info[:klass]
          color = piece_info[:color]
          pos = {row: row_idx, col: col_idx}
          klass.new(color, pos, self)
        end
      end
    else
      @grid = grid
      grid.flatten.each {|piece| piece.board = self}
    end
  end

  #Returns color of piece at board
  def player_color(pos)
    self[pos].color
  end

  def Board.move_hash(pos, color)
    {pos: pos.dup, color: color}
  end

  def [](pos)
    grid[pos[:row]][pos[:col]]
  end

  def hypothetical_check(start_pos = [nil, nil], end_pos = [nil, nil], color)
    #Create duplicated board.
    fake_grid = @grid.map do |grid_row|
      grid_row.map {|piece| piece.class.new(piece.color, piece.pos, nil)}
    end
    fake_board = Board.new(fake_grid)
    fake_board.move!(start_pos, end_pos)
    in_check = fake_board.in_check?(color)
    in_check
  end

  def in_check?(color)
    our_king = grid.flatten.find {|piece| piece.color == color && piece.is_a?(King)}
    opponent_color = (color == :white ? :black : :white)
    opponent_pieces = grid.flatten.select {|piece| piece.color == opponent_color}
    puts "opponent_pieces.count = #{opponent_pieces.count}"
    opponent_pieces.any? {|piece| piece.possible_moves.include?(our_king.pos)}
    opponent_pieces.each do |piece|
      puts "piece.pos (#{piece.pos}) => piece.possible_moves (#{piece.possible_moves})"
    end
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
        break if (move_pos[:row] - pos[:row]).abs > max_travel * offsets[:row].abs
        break if (move_pos[:col] - pos[:col]).abs > max_travel * offsets[:col].abs
      end
    end
    moves.delete_if {|el| el[:pos] == pos}#don't inlcude starting_position
    moves
  end

  public
  def diagonal_moves(pos, max_travel=8)
    moves(pos, DIAGONAL_STEPS, max_travel)
  end

  def lateral_moves(pos, max_travel=8)
    moves(pos, LATERAL_STEPS, max_travel)
  end

  def knight_moves(pos)
    moves(pos, KNIGHT_STEPS, 1)
  end

  def pawn_moves(pos, moved)
    color = self[pos].color
    direction = (color == :white ? -1 : 1)
    moves = []
    new_pos = {row: pos[:row] + 2 * direction, col: pos[:col]}
    moves << new_pos unless moved || occupied?(new_pos)

    new_pos = {row: pos[:row] + 1 * direction, col: pos[:col]}
    moves << new_pos unless occupied?(new_pos)

    # new_pos = {row: pos[:row] + 1 * direction, col: pos[:col] + 1}
    # moves << new_pos if occupied?(new_pos) && owner(new_pos) != color

    # new_pos = {row: pos[:row] + 1 * direction, col: pos[:col] - 1}
    # moves << new_pos if occupied?(new_pos) && owner(new_pos) != color
    moves
  end

  def owner(pos)
    self[pos].color
  end

  def move(from, to)
    if valid_move?(from, to)
      move!(from, to)
    end
  end

  def move!(from, to)
    piece = self[from]
    piece.pos = to
    piece.moved = true

    grid[to[:row]][to[:col]] = piece#Eventually write capture method for if piece exists at to.
    grid[from[:row]][from[:col]] = EmptyPiece.new(:default, from, self)
  end

  def valid_move?(from, to) #delete this eventually. Working on new methods.
    self[from].valid_move?(to)
  end

end
