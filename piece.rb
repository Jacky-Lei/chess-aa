#Holds piece data; where a piece can move; how a piece can attack; features of special pieces
#What can a piece do? Move, Capture, Die.

# piece.valid_move?(new_pos) returns true if a piece is theoretically capable
# of making such a move, without regard to other pieces or board space.
# only returns false for moves that are ALWAYS invalid.
# board should handle other checks (blocking pieces, wrong attacked color, check, etc.)


=begin #refactor and Notes
Create new methods valid_diagonal, valid_horizontal, valid_vertical, ...
Create new methods in Board along_diagonal, along ... (return all pieces along given direction)
Also check that move does not create suicidal conditions. (Own check.)
Create methods for valid_moves (return all valid moves a piece can make)
=end
class Piece
  attr_reader :color, :board
  attr_accessor :pos, :moved, :board

  def initialize(color, pos, board)
    @color = color
    @pos = pos
    @moved = false
    @board = board
  end

  def empty?
    false
  end

  def to_s(character = " ")
    " " + character + " "
  end

  def valid_move?(new_pos)
    return valid_moves.include?(new_pos)
  end

  def valid_moves(check_next_level=true)
    res = possible_moves.delete_if do |move_data|
      move_data[:color] == self.color || (check_next_level && board.hypothetical_check(pos, move_data[:pos], self.color))
    end.map {|move_data| move_data[:pos]}
  end

end

class Pawn < Piece
  def to_s
    super("♙")
  end

  def possible_moves(check_next_level=true)
    moves_data = board.pawn_moves(pos, @moved)
    # p "Do we make it to here?"
    # super(moves_data, check_next_level)
  end

  def valid_moves
    possible_moves
  end

end

class Bishop < Piece
  def to_s
    super("♗")
  end

  def possible_moves(check_next_level=true)
    move_data = board.diagonal_moves(pos)
    # move_data.map {|key, value| value[:pos]}

  end
end

class Knight < Piece
  def to_s
    super("♘")
  end

  def possible_moves(check_next_level=true)
    move_data = board.knight_moves(pos)
    # move_data.map {|key, value| value[:pos]}

  end
end

class Rook < Piece
  def to_s
    super("♖")
  end

  def possible_moves(check_next_level=true)
    move_data = board.lateral_moves(pos)
    # move_data.map {|key, value| value[:pos]}

  end
end

class Queen < Piece
  def to_s
    super("♕")
  end

  def possible_moves(check_next_level=true)
    moves_data = board.diagonal_moves(pos) + board.lateral_moves(pos)
    move_data.map {|key, value| value[:pos]}

  end
end

class King < Piece
  def to_s
    super("♔")
  end

  def possible_moves(check_next_level=true)
    move_data = board.lateral_moves(pos, 1) + board.diagonal_moves(pos, 1)
    move_data.map {|key, value| value[:pos]}

  end
end

class EmptyPiece < Piece
  def valid_move?(to)
    return false
  end

  def possible_moves(check_next_level=true)
    []
  end

  def empty?
    true
  end
end
