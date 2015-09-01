#Handles primary game loop; talks with board, players, display
# require_relative "board"
# require_relative "display"
# require_relative "piece"
# require_relative "player"
# require_relative "cursor_input"
# require_relative "cursor"
=begin
Refactor Notes
Create a hash to encapsulate positions {row: 0, col: 0}
Move handling of moving pieces to another method outside Cursor#select!

=end
load "board.rb"
load "display.rb"
load "piece.rb"
load "player.rb"
load "cursor.rb"
load "cursor_input.rb"
require "colorize"

class Game
  attr_accessor :key_press
  attr_reader :display, :board, :cursor
  include KeyPress

  def initialize
    @key_press = nil
    @board = Board.new
    @cursor = Cursor.new(@board)
    @display = Display.new(@board, @cursor)
  end

  def play
    until game_over?
      display.render
      @key_press = get_key_press
      process_key_press
    end
    game_over!
  end

  def game_over?
    false
    #Will eventually check win/lose/draw conditions.
  end

  def game_over!
    false
    #Final messages, display winner, etc.
  end
end

if __FILE__ == $PROGRAM_NAME
  Game.new.play
end
