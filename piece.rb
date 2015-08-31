#Holds piece data; where a piece can move; how a piece can attack; features of special pieces
#What can a piece do? Move, Capture, Die.

class Piece
  def initialize(color)
    @color = color
  end

  def Piece.generate(type, color)
    case type
    when :pawn
      Pawn.new(color)
    when :bishop
      Bishop.new(color)
    when :knight
      Knight.new(color)
    when :rook
      Rook.new(color)
    when :queen
      Queen.new(color)
    when :king
      King.new(color)
    else
      EmptyPiece.new
    end
  end

  def to_s(character = "#")
    character
  end

end

class Pawn < Piece
  def to_s
    super("♙")
  end
end

class Bishop < Piece
  def to_s
    super("♗")
  end
end

class Knight < Piece
  def to_s
    super("♘")
  end
end

class Rook < Piece
  def to_s
    super("♖")
  end
end

class Queen < Piece
  def to_s
    super("♕")
  end
end

class King < Piece
  def to_s
    super("♔")
  end
end

class EmptyPiece < Piece
  def initialize; end #No color.
end
