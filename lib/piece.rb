# frozen_string_literal: true

require './lib/location'

# class to implement chess pieces
class Piece
  include Location
  attr_accessor :location, :color, :name

  def initialize(location)
    @location = location
  end

  def valid_move?(dest_loc, capture, board)
    if capture
      possible_captures(board).include?(dest_loc)
    else
      possible_moves(board).include?(dest_loc)
    end
  end
end

class WhitePawn < Piece
  def initialize(location)
    super
    @color = 'W'
  end

  def possible_moves(board)
    result = []
    file, rank = loc_to_coord(@location)
    result << coord_to_loc(file, rank + 1) if board.valid_square?(file, rank + 1) && board.empty?(file, rank + 1)
    result << coord_to_loc(file, rank + 2) if rank == 1 && board.empty?(file, rank + 1) && board.empty?(file, rank + 2)
    result
  end

  def possible_captures(board)
    result = []
    file, rank = loc_to_coord(@location)
    result << coord_to_loc(file - 1, rank + 1) if board.valid_square?(file - 1, rank + 1) && board.enemy_piece?(file - 1, rank + 1, @color)
    result << coord_to_loc(file + 1, rank + 1) if board.valid_square?(file + 1, rank + 1) && board.enemy_piece?(file + 1, rank + 1, @color)
    result
  end
end

class BlackPawn < Piece
  def initialize(location)
    super
    @color = 'B'
  end
  def valid_move?(dest_loc, capture, board)
  end
end

class WhiteKnight < Piece
  def initialize(location)
    super
    @color = 'W'
  end
  def valid_move?(dest_loc, capture, board)
  end
end

class BlackKnight < Piece
  def initialize(location)
    super
    @color = 'B'
  end
  def valid_move?(dest_loc, capture, board)
  end
end

class WhiteBishop < Piece
  def initialize(location)
    super
    @color = 'W'
  end
  def valid_move?(dest_loc, capture, board)
  end
end

class BlackBishop < Piece
  def initialize(location)
    super
    @color = 'B'
  end
  def valid_move?(dest_loc, capture, board)
  end
end

class WhiteRook < Piece
  def initialize(location)
    super
    @color = 'W'
  end
  def valid_move?(dest_loc, capture, board)
  end
end

class BlackRook < Piece
  def initialize(location)
    super
    @color = 'B'
  end
  def valid_move?(dest_loc, capture, board)
  end
end

class WhiteQueen < Piece
  def initialize(location)
    super
    @color = 'W'
  end
  def valid_move?(dest_loc, capture, board)
  end
end

class BlackQueen < Piece
  def initialize(location)
    super
    @color = 'B'
  end
  def valid_move?(dest_loc, capture, board)
  end
end

class WhiteKing < Piece
  def initialize(location)
    super
    @color = 'W'
  end
  def valid_move?(dest_loc, capture, board)
  end
end

class BlackKing < Piece
  def initialize(location)
    super
    @color = 'B'
  end
  def valid_move?(dest_loc, capture, board)
  end
end
