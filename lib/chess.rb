# frozen_string_literal: true

require './lib/piece'

#Main Chess game class
class Chess
  Dim = 8
  def initialize
    @turn = 'W'
    @board = Array.new(Dim) { Array.new(Dim, nil) }
    @piece_to_loc_hash = { }
  end

  def setup_board
    clear_board
    setup_pieces('W')
    setup_pieces('B')
  end

  def setup_piece(color)
    setup_pawns(color)
    setup_rooks(color)
    setup_knights(color)
    setup_bishops(color)
    setup_queen(color)
    setup_king(color)
  end

  def setup_pawns(color)
    name = "p1" + color
    create_pawn(name, color, 'a2')
   
    Dim.times do |index|
      name = "p#{index}#{color}"
      loc = "#{(a.ord + index).chr}2"
      create_pawn(name, color, loc)
    end

  end

  def create_pawn(name, color, loc)
    piece = Pawn.new(name, color, loc)
    @piece_to_loc_hash{ name.to_sym => piece }
    set_board_loc(loc, piece)
  end

  def set_board_loc(alpha_loc, piece)
    row, col = alpha_to_coord(alpha_loc)
    @board[row][col] = piece
  end

  def clear_board
    @board.each { |row| row.each { |sq| sq = nil } }
  end

  def play_game
    setup_board
    loop do
      move = user_input
      (move = user_input) until parse_and_execute_user_input == true
      print_board
      break if checkmate?
      print_check if check?
      change_turn
    end
    print_winner_message
  end

  def change_turn
    @turn == 'W' ? @turn = 'B' : @turn = 'W'
  end
end