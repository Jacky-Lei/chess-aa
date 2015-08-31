#Handles primary game loop; talks with board, players, display
# require_relative "board"
# require_relative "display"
# require_relative "piece"
# require_relative "player"

load "board.rb"
load "display.rb"
load "piece.rb"
load "player.rb"

class Game

  def initialize

  end

  def play
    until game_over?
      render_board
      take_player_turn
      execute_player_turn
    end
    game_over!
  end
end
