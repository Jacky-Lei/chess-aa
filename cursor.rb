class Cursor
  attr_reader :row_range, :col_range, :board
  attr_accessor :pos, :selected_pos

  def initialize(board, row_range = (0..7), col_range = (0..7))
    @pos = [0, 0]
    @row_range = row_range
    @col_range = col_range
    @selected_pos = [nil, nil]
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
    elsif !selected?([nil, nil]) #second move
      board.move(selected_pos, pos) #move me!
      deselect!
    else
      self.selected_pos = pos
    end
  end

  def deselect!
    self.selected_pos = [nil, nil] #consider special class
  end

  def move(direction)
    offsets = {
      up: [-1, 0],
      down: [1, 0],
      right: [0, 1],
      left: [0, -1]
    }

    offset = offsets[direction]
    raise "Invalid Direction" if offset.nil?

    new_pos = [pos[0] + offset[0], pos[1] + offset[1]]
    self.pos = new_pos if valid?(new_pos)
  end

  def valid?(pos)
    row = pos[0]
    col = pos[1]
    return false unless (row_range.include?(row) && col_range.include?(col))
    true
  end
end
