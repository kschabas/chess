# frozen_string_literal: true

require './lib/piece'
require './lib/location'
require './lib/board'
require 'colorize'

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

  def get_piece_from_loc(loc)
    @piece_to_loc_hash[loc.to_sym]
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
      move = user_input until parse_and_execute_user_input(move) == true

      print_board
      break if checkmate? || stalemate?

      print_check if check?
      change_turn
    end
    print_winner_message
  end

  def print_winner_message
    color = (@turn == 'W') ? 'White' : 'Black'
    puts "Checkmate!! #{color} wins!!!"
  end

  def print_check
    puts 'Check!'
  end

  def print_board
    @board.grid.reverse.each_with_index { |row, index| print_row(row, index.odd?) }
  end

  def print_row(row, odd)
    row.each_with_index do |square, index| 
      if (!odd && index.even?) || (odd && index.odd?)
        print_square(square, true)
      else
        print_square(square, false)
      end
    end
    print "\n"
  end

  def print_square(square, color)
    if square.nil?
      print_empty_square(color)
    else
      print_icon(square, color)
    end
  end

  def print_icon(piece, color)
    if color
      print "#{piece.ucode} ".colorize(background: :red)
    else
      print "#{piece.ucode} ".colorize(background: :blue)
    end
  end

  def print_empty_square(color)
    if color
      print '  '.colorize(background: :red)
    else
      print '  '.colorize(background: :blue)
    end
  end

  def stalemate?
    false
  end

  def check?(color = @turn)
    enemy_king = @piece_to_loc_hash.reject { |_key, piece| piece.color == color || !piece.is_a?(King) }
    enemy_king_loc = enemy_king.keys[0].to_s
    possible_king_attackers = @piece_to_loc_hash.select { |_key, piece| piece.color == color && piece.valid_move?(enemy_king_loc, true, @board)}
    possible_king_attackers.size.positive? ? true : false
  end

  def checkmate?
    return false unless check?

    enemy_pieces = @piece_to_loc_hash.reject { |_key, piece| piece.color == @turn }
    enemy_pieces.each_value do |piece|
      start_loc = piece.location
      possible_moves = piece.possible_moves(@board)
      possible_captures = piece.possible_captures(@board)
      possible_moves.each do |loc|
        execute_move(piece, loc, false, false)
        result = check?
        undo_move(piece, start_loc, loc, nil, false)
        return false unless result
      end
      possible_captures.each do |loc|
        saved_piece = @piece_to_loc_hash[loc.to_sym]
        execute_move(piece, loc, true, false)
        result = check?
        undo_move(piece, start_loc, loc, saved_piece, true)
        return false unless result
      end
    end
    true
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

  def print_bad_input_error(input)
    puts "Unable to interpret the move #{input}. Please try again using standard algebraic notation"
    false
  end

  def print_no_start_piece_error(input)
    puts 'Unable to find a piece of the given type that can move to the desired location. Please try again'
    false
  end

  def print_ambigous_start_piece_error(input)
    puts 'Found more than one piece of the desired type that can move to the given location. Please be more specific.'
    false
  end

  def print_exposes_king_error(input)
    puts 'That move is illegal as it allows your king to be captured. Please try again'
  end

  def castle_move(input)
    result = if input == 'O-O'
               king_side_castle
             else
               queen_side_castle
             end
    print_castling_error unless result
    result
  end

  def print_castling_error
    puts "Castling is illegal in this situation. Please try again!"
  end

  def king_side_castle
    if @turn == 'W'
      king_loc = 'e1'
      rook_loc = 'h1'
      empty_space = ['f1', 'g1']
      king_dest = 'g1'
      rook_dest = 'f1'
    else
      king_loc = 'e8'
      rook_loc = 'h8'
      empty_space = ['f8', 'g8']
      king_dest = 'g8'
      rook_dest = 'f8'
    end
    execute_castle(king_loc, rook_loc, empty_space, king_dest, rook_dest)
  end

  def is_space_attacked?(loc, color)
    possible_attackers = @piece_to_loc_hash.select { |_key, piece| piece.color == color && piece.valid_move?(loc, false, @board) }
    possible_attackers.size.positive? ? true : false
  end

  def execute_castle(king_loc, rook_loc, empty_space, king_dest, rook_dest)
    king_piece = @piece_to_loc_hash[king_loc.to_sym]
    rook_piece = @piece_to_loc_hash[rook_loc.to_sym]
    return false unless king_piece.is_a?(King)
    return false unless rook_piece.is_a?(Rook)
    return false if king_piece.moved || rook_piece.moved

    return false if check?(enemy_color(@turn))
    return false unless empty_space.all? { |loc| @board.empty?(loc_to_coord(loc)[0], loc_to_coord(loc)[1]) }
    return false unless empty_space.none? { |loc| is_space_attacked?(loc, enemy_color(@turn)) }

    execute_move(king_piece, king_dest, false)
    execute_move(rook_piece, rook_dest, false)
    if check?(enemy_color(@turn))
      execute_move(king_piece, king_loc, false)
      execute_move(rook_piece, rook_loc, false)
      king_piece.moved = false
      rook_piece.moved = false
      return false
    end
    true
  end

  def queen_side_castle
    if @turn == 'W'
      king_loc = 'e1'
      rook_loc = 'a1'
      empty_space = ['b1', 'c1', 'd1']
      king_dest = 'c1'
      rook_dest = 'd1'
    else
      king_loc = 'e8'
      rook_loc = 'a8'
      empty_space = ['b8', 'c8', 'd8']
      king_dest = 'c8'
      rook_dest = 'd8'
    end
    execute_castle(king_loc, rook_loc, empty_space, king_dest, rook_dest)
  end

  def parse_and_execute_user_input(input)
    return save_game if input == 'save'

    castle_moves = ['o-o-o', 'o-o']
    return castle_move(input) if castle_moves.include?(input)

    result = parse_move(input)
    return print_bad_input_error(input) if result.nil?

    piece_type, capture, dest_loc, piece_start_loc = result
    start_piece = find_piece(piece_type, capture, dest_loc, piece_start_loc)
    return print_no_start_piece_error(input) if start_piece.nil?

    return print_ambigous_start_piece_error(input) if start_piece.size > 1

    start_piece = start_piece.values[0]
    return print_exposes_king_error(input) if exposes_king?(start_piece, dest_loc, capture)

    execute_move(start_piece, dest_loc, capture, true)
  end

  def execute_move(start_piece, dest_loc, capture, permanent = true)
    start_piece.moved = true if permanent && (start_piece.is_a?(King) || start_piece.is_a?(Rook))
    remove_piece(dest_loc) if capture

    remove_piece(start_piece.location)
    start_piece.location = dest_loc
    add_piece(start_piece, dest_loc)
    true
  end

  def exposes_king?(start_piece, dest_loc, capture)
    dest_file, dest_rank = loc_to_coord(dest_loc)
    saved_piece = @board.grid[dest_file][dest_rank] if capture
    start_loc = start_piece.location
    king_piece = @piece_to_loc_hash.select { |_key, piece| piece.color == start_piece.color && piece.is_a?(King) }
    king_piece = king_piece.values[0]

    execute_move(start_piece, dest_loc, capture, false)
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
      piece.is_a?(letter_to_type(piece_type, @turn)) && piece.location.include?(piece_start_loc)
    end
    result = possible_pieces.select { |_key, piece| piece.valid_move?(dest_loc, capture, @board) }
    result.size.positive? ? result : nil
  end

  def letter_to_type(piece_type, color)
    case piece_type
    when 'p'
      if color == 'W'
        WhitePawn
      else
        BlackPawn
      end
    when 'r'
      if color == 'W'
        WhiteRook
      else
        BlackRook
      end
    when 'n'
      if color == 'W'
        WhiteKnight
      else
        BlackKnight
      end
    when 'b'
      if color == 'W'
        WhiteBishop
      else
        BlackBishop
      end
    when 'q'
      if color == 'W'
        WhiteQueen
      else
        BlackQueen
      end
    when 'k'
      if color == 'W'
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