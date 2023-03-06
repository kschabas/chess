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

  def setup_rooks(color)
    if color == 'W'
      create_rook('R1W', 'W', 'a1')
      create_rook('R2W', 'W', 'h1')
    else
      create_rook('R1B', 'B', 'a8')
      create_rook('R2B', 'B', 'h8')
    end
  end

  def setup_knights(color)
    if color == 'W'
      create_knight('N1W', 'W', 'b1')
      create_knight('N2W', 'W', 'g1')
    else
      create_knight('N1B', 'B', 'b8')
      create_knight('N2B', 'B', 'g8')
    end
  end

  def setup_bishops(color)
    if color == 'W'
      create_bishop('B1W', 'W', 'c1')
      create_bishop('B1W', 'W', 'f1')
    else
      create_bishop('B1B', 'B', 'c8')
      create_bishop('B2B', 'B', 'f8')
    end
  end

  def setup_queen(color)
    if color == 'W'
      create_queen('QW', 'W', 'd1')
    else
      create_queen('QB', 'B', 'd8')
    end
  end

  def setup_king(color)
    if color == 'W'
      create_king('KW', 'W', 'e1')
    else
      create_king('KB', 'B', 'e8')
    end
  end

  def setup_pawns(color)  
    Dim.times do |index|
      name = "p#{index + 1}#{color}"
      if color == 'W' 
        loc = "#{('a'.ord + index).chr}2"
      else
        loc = "#{('a'.ord + index).chr}7"
      end
      create_pawn(name, color, loc)
    end
  end
  
  def add_piece(piece)
    @piece_to_loc_hash[piece.name.to_sym] = piece
    set_board_loc(piece.loc, piece)
  end

  def create_pawn(name, color, loc)
    piece = Pawn.new(name, color, loc)
    add_piece(piece)
  end

  def create_rook(name, color, loc)
    piece = Rook.new(name, color, loc)
    add_piece(piece)
  end

  def create_knight(name, color, loc)
    piece = Knight.new(name, color, loc)
    add_piece(piece)
  end

  def create_bishop(name, color, loc)
    piece = Bishop.new(name, color, loc)
    add_piece(piece)
  end

  def create_queen(name, color, loc)
    piece = Queen.new(name, color, loc)
    add_piece(piece)
  end

  def create_king(name, color, loc)
    piece = King.new(name, color, loc)
    add_piece(piece)
  end

  def set_board_loc(alpha_loc, piece)
    row, col = alpha_to_coord(alpha_loc)
    @board[row][col] = piece
  end

  def alpha_to_coord(alpha_loc)
    row = alpha_loc[1].to_i - 1
    col = alpha_loc[0].ord - 'a'.ord
    return row, col
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