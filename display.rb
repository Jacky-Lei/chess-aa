#Handles screen output from board;

class Display

  attr_reader :cursor, :board

  def initialize(board, cursor)
    @board = board
    @cursor = cursor
  end

  def render
    system("clear")
    string = ""
    row_letters = %w[8 7 6 5 4 3 2 1]
    footer = "  A  B  C  D  E  F  G  H \n"
    @board.grid.each_with_index do |row, row_idx|
      string << row_letters.shift
      row.each_with_index do |piece, column_idx|
        pos = {row: row_idx, col: column_idx}
        string << piece.to_s.colorize(color(pos))
      end
      string << "\n"
    end
    puts string + footer
    puts "Up/Down/Left/Right = Move | Space = Select | Enter = Move | Escape = Deselect"
  end

  def color(pos)
    background = (pos[:row] + pos[:col]).even? ? :light_blue : :light_green
    background = :yellow if cursor.at?(pos)
    background = :red if cursor.selected?(pos)
    color = board.player_color(pos)

    {color: color, background: background}
  end

end
