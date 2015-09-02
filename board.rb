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

  def [](pos)
    grid[pos[:row]][pos[:col]]
  end

  def []=(pos, set)
    grid[pos[:row]][pos[:col]] = set
  end

  def dup
    dup_grid = []
    grid.each_with_index do |row, r_idx|
      dup_grid[r_idx] = []
      row.each_with_index do |piece, c_idx|
        pos = {row: r_idx, col: c_idx}
        piece = grid[r_idx][c_idx]
        dup_grid[r_idx][c_idx] = piece.class.new(piece.color, pos, nil)
      end
    end
    Board.new(dup_grid)
  end

  def in_check?(color)
    return false unless color == :white || color == :black

    opp_color = (color == :white ? :black : :white)
    king_piece = grid.flatten.find {|piece| piece.color == color && piece.is_a?(King)}

    grid.flatten.any? do |piece|
      piece.color == opp_color && piece.possible_moves.include?(king_piece.pos)
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
    steps.each do |_, offsets|#Clean this up. Ugly
      move_pos = pos
      while on_board?(move_pos)
        move_pos = move_pos.dup
        # moves << Board.move_hash(move_pos, self[move_pos].color)
        moves << move_pos
        break if occupied?(move_pos) unless move_pos == pos

        move_pos[:row] += offsets[:row]
        move_pos[:col] += offsets[:col]
        break if (move_pos[:row] - pos[:row]).abs > max_travel * offsets[:row].abs
        break if (move_pos[:col] - pos[:col]).abs > max_travel * offsets[:col].abs
        # puts offsets
      end
    end
    moves.delete_if {|el| el == pos || !on_board?(el)}#don't inlcude starting_position
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

    one_step = {row: pos[:row] + 1 * direction, col: pos[:col]} #Forward by 1 if not blocked.
    moves << one_step if on_board?(one_step) && !occupied?(one_step)

    two_step = {row: pos[:row] + 2 * direction, col: pos[:col]} #Forward by 2 if not moved.
    moves << two_step if on_board?(two_step) && !moved && !(occupied?(one_step) || occupied?(two_step)) #Missing logic for if there is a pawn at new_pos - 1


    attack_l = {row: pos[:row] + 1 * direction, col: pos[:col] + 1}
    moves << attack_l if on_board?(attack_l) && occupied?(attack_l) && color_of(attack_l) != color

    attack_r = {row: pos[:row] + 1 * direction, col: pos[:col] - 1}
    moves << attack_r if on_board?(attack_r) && occupied?(attack_r) && color_of(attack_r) != color

    moves
  end

  def color_of(pos)
    self[pos].color
  end

  def move(from, to)
    if valid_move?(from, to)
      move!(from, to)
    end
  end

  def valid_move?(from, to)
    piece = self[from]
    moves_to = piece.moves_to?(to) && !(color_of(to)==piece.color)
    tried_move = try_move(from, to)
    moves_to && tried_move
  end

  def try_move(from, to)
    test_board = self.dup
    piece = test_board[from]
    test_board.move!(from, to)#note, Board#dup does not duplicate @moved state for pieces.
    !test_board.in_check?(piece.color)
  end

  def move!(from, to)
    piece = self[from]
    piece.pos = to
    piece.moved = true

    self[to] = piece#Eventually write capture method for if piece exists at to.
    self[from] = EmptyPiece.new(:default, from, self)
  end

end
