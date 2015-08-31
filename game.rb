#Handles primary game loop; talks with board, players, display
# require_relative "board"
# require_relative "display"
# require_relative "piece"
# require_relative "player"
# require_relative "cursor_input"

load "board.rb"
load "display.rb"
load "piece.rb"
load "player.rb"
load "cursor_input.rb"
require "colorize"

class Game
  attr_accessor :key_press

  def initialize
    @key_press = nil
  end

  def play
    until game_over?
      @key_press = get_key_press 
      process_key_press
      print board
    end
    game_over!
  end
end
