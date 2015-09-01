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
  attr_reader :color
  attr_accessor :pos, :moved

  def initialize(color, pos)
    @color = color
    @pos = pos
    @moved = false
  end

  def Piece.generate(type, color, pos)
    case type
    when :pawn
      Pawn.new(color, pos)
    when :bishop
      Bishop.new(color, pos)
    when :knight
      Knight.new(color, pos)
    when :rook
      Rook.new(color, pos)
    when :queen
      Queen.new(color, pos)
    when :king
      King.new(color, pos)
    else
      EmptyPiece.new(color, pos)
    end
  end

  def to_s(character = " ")
    " " + character + " "
  end

  def valid_move?(new_pos)
    row_offset = new_pos[0] - pos[0]
    col_offset = new_pos[1] - pos[1]
    return false if (row_offset == 0 && col_offset == 0)
    true
  end

end

class Pawn < Piece
  def to_s
    super("♙")
  end

  def valid_move?(new_pos)
    return false unless super
    row_offset = new_pos[0] - pos[0]
    col_offset = new_pos[1] - pos[1]

    offsets = [row_offset, col_offset]
    valid_direction = (color == :white ? -1 : 1)
    return true if offsets == [valid_direction * 1, 0]
    return true if offsets == [valid_direction * 2, 0] && !moved
    return true if offsets == [valid_direction * 1, 1]#forward, right
    return true if offsets == [valid_direction * 1, -1]#forward, left
    #need to check en passant
    false
  end
end

class Bishop < Piece
  def to_s
    super("♗")
  end

  def valid_move?(new_pos)
    return false unless super
    row_offset = new_pos[0] - pos[0]
    col_offset = new_pos[1] - pos[1]
    return true if row_offset.abs == col_offset.abs
    false
  end
end

class Knight < Piece
  def to_s
    super("♘")
  end

  def valid_move?(new_pos)
    return false unless super
    row_offset = new_pos[0] - pos[0]
    col_offset = new_pos[1] - pos[1]

    offsets = [row_offset.abs, col_offset.abs].sort
    return true if offsets == [1, 2]
    false
  end
end

class Rook < Piece
  def to_s
    super("♖")
  end

  def valid_move?(new_pos)
    return false unless super
    row_offset = new_pos[0] - pos[0]
    col_offset = new_pos[1] - pos[1]
    return true if (row_offset == 0 || col_offset == 0)
    false
  end
end

class Queen < Piece
  def to_s
    super("♕")
  end

  def valid_move?(new_pos)
    return false unless super
    row_offset = new_pos[0] - pos[0]
    col_offset = new_pos[1] - pos[1]
    return true if row_offset.abs == col_offset.abs
    return true if (row_offset == 0 || col_offset == 0)
    false
  end
end

class King < Piece
  def to_s
    super("♔")
  end
  def valid_move?(new_pos)
    return false unless super
    row_offset = new_pos[0] - pos[0]
    col_offset = new_pos[1] - pos[1]
    return true if row_offset.abs <= 1 && col_offset.abs <= 1
    false
  end
end

class EmptyPiece < Piece
  def valid_move?(to)
    return false
  end
end
