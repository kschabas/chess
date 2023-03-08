# frozen_string_literal: true

require './lib/piece'

# Main Chess game class
class Chess
  DIM = 8
  def initialize
    @turn = 'W'
    @board = Array.new(DIM) { Array.new(DIM, nil) }
    @piece_to_loc_hash = {}
  end

  def setup_board
    clear_board
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
      create_bishop('B2W', 'W', 'f1')
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
    DIM.times do |index|
      name = "p#{index + 1}#{color}"
      loc = if color == 'W'
              "#{('a'.ord + index).chr}2"
            else
              "#{('a'.ord + index).chr}7"
            end
      create_pawn(name, color, loc)
    end
  end

  def add_piece(piece)
    @piece_to_loc_hash[piece.name.to_sym] = piece
    set_board_loc(piece.location, piece)
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
    [row, col]
  end

  def clear_board
    @board.each_index { |row| @board[row].each_index { |col| @board[row][col] = nil } }
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
    save_game if input == 'save'

    result = parse_move(input)
    return false if result.nil?

    piece_type, capture, dest_loc, piece_start_loc = result
    start_piece = find_piece(piece_type, capture, dest_loc, piece_start_loc)
    return false if start_piece.nil?

    execute_move(start_piece, dest_loc)
    true
  end

  def find_piece(piece_type, capture, dest_loc, piece_start_loc)
    possible_pieces = @piece_to_loc_hash.select do |_key, piece|
      piece.is_a?(letter_to_type(piece_type)) && piece.loc.include?(piece_start_loc) &&
        piece.color == @turn
    end
    result = possible_pieces.select { |_key, piece| piece.valid_move?(dest_loc, capture) }
    result.size == 1 ? result[0] : nil
  end

  def letter_to_type(piece_type)
    case piece_type
    when 'p'
      Pawn
    when 'r'
      Rook
    when 'n'
      Knight
    when 'b'
      Bishop
    when 'q'
      Queen
    when 'k'
      King
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
