#Handles screen output from board;

class Display
  def initialize(board)
    @board = board
  end

  def render
    string = ""
    row_letters = %w[8 7 6 5 4 3 2 1]
    footer = "  A  B  C  D  E  F  G  H \n"
    @board.grid.each_with_index do |row, row_idx|
      string << row_letters.shift
      row.each_with_index do |piece, column_idx|
        pos = [row_idx, column_idx]
        string << piece.to_s.colorize(color(pos))
      end
      string << "\n"
    end
    string + footer
  end

  def color(pos)
    background = (pos[0] + pos[1]).even? ? :light_blue : :light_green
    background = :red if cursor.at(pos)
    background = :yellow if cursor.selected(pos)
    color = board.player_color(pos)

    {color: color, background: background}
  end

end

class Cursor
  attr_reader :row_pos, :col_pos, :row_range, :col_range
  def initialize(row_range = (0..7), col_range = (0..7))
    @pos = [0, 0]
    @row_range = row_range
    @col_range = col_range
  end

  def pos
    [@row_pos, @col_pos]
  end

  def move(direction)
    offsets = {
      up: [-1, 0],
      down: [1, 0],
      right: [0, 1],
      left: [0, -1]
    }
    offset = offsets[direction]
    new_pos = [pos[0] + offset[0], pos[1] + offset[1]]
    pos = new_pos if valid?(new_pos)
  end

  def valid?(pos)
    row = pos[0]
    col = pos[1]
    return false unless (row_range.include?(row) && col_range.include?(col))
  end
end
