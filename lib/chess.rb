# frozen_string_literal: true

require './lib/piece'
require './lib/location'
require './lib/board'

# Main Chess game class
class Chess
  include Location
  def initialize
    @turn = 'W'
    @piece_to_loc_hash = {}
    @board = Board.new
  end

  def setup_board
    @board.clear_board
    setup_pieces('W')
    setup_pieces('B')
  end

  def setup_pieces(color)
    setup_pawns(color)
    setup_rooks(color)
    setup_knights(color)
    setup_bishops(color)
    setup_queen(color)
    setup_king(color)
  end

  def setup_rooks(color)
    if color == 'W'
      create_rook('W', 'a1')
      create_rook('W', 'h1')
    else
      create_rook( 'B', 'a8')
      create_rook('B', 'h8')
    end
  end

  def setup_knights(color)
    if color == 'W'
      create_knight('W', 'b1')
      create_knight('W', 'g1')
    else
      create_knight('B', 'b8')
      create_knight('B', 'g8')
    end
  end

  def setup_bishops(color)
    if color == 'W'
      create_bishop('W', 'c1')
      create_bishop('W', 'f1')
    else
      create_bishop('B', 'c8')
      create_bishop('B', 'f8')
    end
  end

  def setup_queen(color)
    if color == 'W'
      create_queen('W', 'd1')
    else
      create_queen('B', 'd8')
    end
  end

  def setup_king(color)
    if color == 'W'
      create_king('W', 'e1')
    else
      create_king('B', 'e8')
    end
  end

  def setup_pawns(color)
    8.times do |index|
      loc = if color == 'W'
              "#{('a'.ord + index).chr}2"
            else
              "#{('a'.ord + index).chr}7"
            end
      create_pawn(color, loc)
    end
  end

  def add_piece(piece, location)
    piece.location = location
    @piece_to_loc_hash[location.to_sym] = piece
    @board.add_piece(piece, location)
  end

  def remove_piece(location)
    piece = @piece_to_loc_hash[location.to_sym]
    piece.location = nil
    @piece_to_loc_hash.delete(location.to_sym)
    @board.remove_piece(location)
  end

  def create_pawn(color, loc)
    piece = if color == 'W'
              WhitePawn.new(loc)
            else
              BlackPawn.new(loc)
            end
    add_piece(piece, loc)
  end

  def create_rook(color, loc)
    if (color == 'W')
      piece = WhiteRook.new(loc)
    else
      piece = BlackRook.new(loc)
    end
    add_piece(piece, loc)
  end

  def create_knight(color, loc)
    if (color == 'W')
      piece = WhiteKnight.new(loc)
    else
      piece = BlackKnight.new(loc)
    end
    add_piece(piece, loc)
  end

  def create_bishop(color, loc)
    if (color == 'W')
      piece = WhiteBishop.new(loc)
    else
      piece = BlackBishop.new(loc)
    end
    add_piece(piece, loc)
  end

  def create_queen(color, loc)
    if (color == 'W')
      piece = WhiteQueen.new(loc)
    else
      piece = BlackQueen.new(loc)
    end
    add_piece(piece, loc)
  end

  def create_king(color, loc)
    if (color == 'W')
      piece = WhiteKing.new(loc)
    else
      piece = BlackKing.new(loc)
    end
    add_piece(piece, loc)
  end

  def play_game
    setup_board
    loop do
      move = user_input
      until parse_and_execute_user_input(move) == true
        print_input_error_message(move)
        move = user_input
      end
      print_board
      break if checkmate?

      print_check if check?
      change_turn
    end
    print_winner_message
  end

  def change_turn
    @turn = @turn == 'W' ? 'B' : 'W'
  end

  def user_input
    puts 'Please enter your move using standard algebraic notation (or Save to save the game)'
    if @turn == 'W'
      puts "White's move"
    else
      puts "Black's move"
    end
    gets.chomp.downcase
  end

  def parse_and_execute_user_input(input)
    return save_game if input == 'save'

    result = parse_move(input)
    return print_bad_input_error(input) if result.nil?

    piece_type, capture, dest_loc, piece_start_loc = result
    start_piece = find_piece(piece_type, capture, dest_loc, piece_start_loc)
    return print_no_start_piece_error(input) if start_piece.nil?

    return print_ambigous_start_piece_error(input) if start_piece.size > 1

    return print_exposes_king_error(input) if exposes_king?(start_piece, dest_loc, capture)

    execute_move(start_piece, dest_loc, capture)
  end

  def execute_move(start_piece, dest_loc, capture)
    remove_piece(dest_loc) if capture

    remove_piece(start_piece.location)
    start_piece.location = dest_loc
    add_piece(start_piece, dest_loc)
  end

  def exposes_king?(start_piece, dest_loc, capture)
    dest_file, dest_rank = loc_to_coord(dest_loc)
    saved_piece = @board.grid[dest_file][dest_rank] if capture
    start_loc = start_piece.location
    king_piece = @piece_to_loc_hash.select { |_key, piece| piece.color == start_piece.color && piece.is_a?(King) }
    king_piece = king_piece.values[0]

    execute_move(start_piece, dest_loc, capture)
    test_for_check = @piece_to_loc_hash.reject { |_key, piece| piece.color == start_piece.color }
    if test_for_check.any? { |_key, piece| piece.valid_move?(king_piece.location, true, @board) }
      undo_move(start_piece, start_loc, dest_loc, saved_piece, capture)
      return true
    end
    undo_move(start_piece, start_loc, dest_loc, saved_piece, capture)
    false
  end

  def undo_move(start_piece, start_loc, dest_loc, saved_piece, capture)
    remove_piece(dest_loc)
    if capture
      saved_piece.location = dest_loc
      add_piece(saved_piece, dest_loc)
    end
    add_piece(start_piece, start_loc)
  end

  def find_piece(piece_type, capture, dest_loc, piece_start_loc)
    possible_pieces = @piece_to_loc_hash.select do |_key, piece|
      piece.is_a?(letter_to_type(piece_type, @turn)) && piece.loc.include?(piece_start_loc)
    end
    result = possible_pieces.select { |_key, piece| piece.valid_move?(dest_loc, capture, @board) }
    result.size == 1 ? result[0] : nil
  end

  def letter_to_type(piece_type, color)
    case piece_type
    when 'p'
      if color == 'W"'
        WhitePawn
      else
        BlackPawn
      end
    when 'r'
      if color == 'W"'
        WhiteRook
      else
        BlackRook
      end
    when 'n'
      if color == 'W"'
        WhiteKnight
      else
        BlackKnight
      end
    when 'b'
      if color == 'W"'
        WhiteBishop
      else
        BlackBishop
      end
    when 'q'
      if color == 'W"'
        WhiteQueen
      else
        BlackQueen
      end
    when 'k'
      if color == 'W"'
        WhiteKing
      else
        BlackKing
      end
    else
      'Error'
    end
  end

  def parse_move(input)
    parse = input.match(/^(?<piece>[rnbqkp])(?<start_loc>[1-8a-h]?)(?<capture>[xX]?)(?<dest_loc>[a-h][1-8])$/)

    return nil if parse.nil?

    capture = !parse[:capture].empty?
    [parse[:piece], capture, parse[:dest_loc], parse[:start_loc]]
  end
end
