class Cursor
  attr_reader :row_range, :col_range, :board
  attr_accessor :pos, :selected_pos

  def initialize(board, row_range = (0..7), col_range = (0..7))
    @pos = {row: 0, col: 0}
    @row_range = row_range
    @col_range = col_range
    @selected_pos = {row: nil, col: nil}
    @board = board
  end

  def at?(pos)
    pos == self.pos
  end

  def selected?(pos)
    selected_pos == pos
  end

  def select!
    if selected?(pos)
      deselect!
    elsif !selected?(NIL_POSITION) #second move
      board.move(selected_pos, pos) #move me!
      deselect!
    else
      self.selected_pos = pos
    end
  end

  def deselect!
    self.selected_pos = NIL_POSITION #consider special class
  end

  def move(direction)
    offsets = {
      up: {row: -1, col: 0},
      down: {row: 1, col: 0},
      right: {row: 0, col: 1},
      left: {row: 0, col: -1}
    }

    offset = offsets[direction]
    raise "Invalid Direction" if offset.nil?
    p pos
    new_pos = {row: (pos[:row] + offset[:row]), col: (pos[:col] + offset[:col])}
    self.pos = new_pos if valid?(new_pos)
  end

  def valid?(pos)
    row = pos[:row]
    col = pos[:col]
    return false unless (row_range.include?(row) && col_range.include?(col))
    true
  end
end
