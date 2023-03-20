# frozen_string_literal: true

require './lib/location'
require 'json'

# class to implement chess pieces
class Piece
  include Location
  attr_accessor :location, :color, :name, :ucode

  def initialize(location = nil)
    @location = location
  end

  def promote?
    false
  end

  def valid_move?(dest_loc, capture, board)
    if capture
      possible_captures(board).include?(dest_loc)
    else
      possible_moves(board).include?(dest_loc)
    end
  end

  def diagonal_moves(board)
    result = []
    result.concat(path_move(-1, 1, board), path_move(1, 1, board), path_move(-1, -1, board), path_move(1, -1, board))
  end

  def straight_moves(board)
    result = []
    result.concat(path_move(1, 0, board), path_move(-1, 0, board), path_move(0, 1, board), path_move(0, -1, board))
  end

  def path_move(file_move, rank_move, board)
    result = []
    file, rank = loc_to_coord(@location)
    file += file_move
    rank += rank_move
    while board.valid_square?(file, rank) && board.empty?(file, rank)
      result << coord_to_loc(file, rank)
      file += file_move
      rank += rank_move
    end
    result
  end

  def diagonal_captures(board)
    result = []
    result.concat(path_capture(-1, 1, board), path_capture(1, 1, board), path_capture(-1, -1, board), path_capture(1, -1, board))
  end

  def straight_captures(board)
    result = []
    result.concat(path_capture(1, 0, board), path_capture(-1, 0, board), path_capture(0, 1, board), path_capture(0, -1, board))
  end

  def path_capture(file_move, rank_move, board)
    file, rank = loc_to_coord(@location)
    file += file_move
    rank += rank_move
    while board.valid_square?(file, rank)
      return [coord_to_loc(file, rank)] if board.enemy_piece?(file, rank, @color)
      break unless board.empty?(file, rank)

      file += file_move
      rank += rank_move
    end
    []
  end

  def to_json(*)
    JSON.dump({
                type: self.class
              })
  end

  def moved_parameter?
    is_a?(King) || is_a?(Rook)
  end
end

class WhitePawn < Piece
  def initialize(location = nil)
    super
    @color = 'W'
    @ucode = "\u265F"
  end

  def possible_moves(board)
    result = []
    file, rank = loc_to_coord(@location)
    result << coord_to_loc(file, rank + 1) if board.valid_and_empty?(file, rank + 1)
    result << coord_to_loc(file, rank + 2) if rank == 1 && board.empty?(file, rank + 1) && board.empty?(file, rank + 2)
    result
  end

  def possible_captures(board)
    result = []
    file, rank = loc_to_coord(@location)
    result << coord_to_loc(file - 1, rank + 1) if board.valid_and_enemy?(file - 1, rank + 1, @color)
    result << coord_to_loc(file + 1, rank + 1) if board.valid_and_enemy?(file + 1, rank + 1, @color)
    result
  end

  def promote?
    _file, rank = loc_to_coord(@location)
    rank == 7
  end
end

class BlackPawn < Piece
  def initialize(location = nil)
    super
    @color = 'B'
    @ucode = "\u2659"
  end

  def promote?
    _file, rank = loc_to_coord(@location)
    rank == 0
  end

  def possible_moves(board)
    result = []
    file, rank = loc_to_coord(@location)
    result << coord_to_loc(file, rank - 1) if board.valid_and_empty?(file, rank - 1)
    result << coord_to_loc(file, rank - 2) if rank == 6 && board.empty?(file, rank - 1) && board.empty?(file, rank - 2)
    result
  end

  def possible_captures(board)
    result = []
    file, rank = loc_to_coord(@location)
    result << coord_to_loc(file - 1, rank - 1) if board.valid_and_enemy?(file - 1, rank - 1, @color)
    result << coord_to_loc(file + 1, rank - 1) if board.valid_and_enemy?(file + 1, rank - 1, @color)
    result
  end
end

class Knight < Piece
  def possible_moves(board)
    result = []
    file, rank = loc_to_coord(@location)
    result << coord_to_loc(file + 1, rank + 2) if board.valid_and_empty?(file + 1, rank + 2)
    result << coord_to_loc(file + 1, rank - 2) if board.valid_and_empty?(file + 1, rank - 2)
    result << coord_to_loc(file + 2, rank + 1) if board.valid_and_empty?(file + 2, rank + 1)
    result << coord_to_loc(file + 2, rank - 1) if board.valid_and_empty?(file + 2, rank - 1)
    result << coord_to_loc(file - 1, rank + 2) if board.valid_and_empty?(file - 1, rank + 2)
    result << coord_to_loc(file - 1, rank - 2) if board.valid_and_empty?(file - 1, rank - 2)
    result << coord_to_loc(file - 2, rank + 1) if board.valid_and_empty?(file - 2, rank + 1)
    result << coord_to_loc(file - 2, rank - 1) if board.valid_and_empty?(file - 2, rank - 1)
    result
  end

  def possible_captures(board)
    result = []
    file, rank = loc_to_coord(@location)
    result << coord_to_loc(file + 1, rank + 2) if board.valid_and_enemy?(file + 1, rank + 2, @color)
    result << coord_to_loc(file + 1, rank - 2) if board.valid_and_enemy?(file + 1, rank - 2, @color)
    result << coord_to_loc(file + 2, rank + 1) if board.valid_and_enemy?(file + 2, rank + 1, @color)
    result << coord_to_loc(file + 2, rank - 1) if board.valid_and_enemy?(file + 2, rank - 1, @color)
    result << coord_to_loc(file - 1, rank + 2) if board.valid_and_enemy?(file - 1, rank + 2, @color)
    result << coord_to_loc(file - 1, rank - 2) if board.valid_and_enemy?(file - 1, rank - 2, @color)
    result << coord_to_loc(file - 2, rank + 1) if board.valid_and_enemy?(file - 2, rank + 1, @color)
    result << coord_to_loc(file - 2, rank - 1) if board.valid_and_enemy?(file - 2, rank - 1, @color)
    result
  end
end

class WhiteKnight < Knight
  def initialize(location = nil)
    super
    @color = 'W'
    @ucode = "\u265E"
  end
end

class BlackKnight < Knight
  def initialize(location = nil)
    super
    @color = 'B'
    @ucode = "\u2658"
  end
end

class Bishop < Piece
  def possible_moves(board)
    diagonal_moves(board)
  end

  def possible_captures(board)
    diagonal_captures(board)
  end
end

class WhiteBishop < Bishop
  def initialize(location = nil)
    super
    @color = 'W'
    @ucode = "\u265D"
  end
end

class BlackBishop < Bishop
  def initialize(location = nil)
    super
    @color = 'B'
    @ucode = "\u2657"
  end
end

class Rook < Piece
  attr_accessor :moved
  def initialize(location = nil)
    @moved = false
    super
  end

  def possible_moves(board)
    straight_moves(board)
  end

  def possible_captures(board)
    straight_captures(board)
  end

  def to_json(*)
    JSON.dump({
                type: self.class,
                moved: @moved
              })
  end
end

class WhiteRook < Rook
  def initialize(location = nil)
    super
    @color = 'W'
    @ucode = "\u265C"
  end
end

class BlackRook < Rook
  def initialize(location = nil)
    super
    @color = 'B'
    @ucode = "\u2656"
  end
end

class Queen < Piece
  def possible_moves(board)
    diagonal_moves(board).concat(straight_moves(board))
  end

  def possible_captures(board)
    diagonal_captures(board).concat(straight_captures(board))
  end
end

class WhiteQueen < Queen
  def initialize(location = nil)
    super
    @color = 'W'
    @ucode = "\u265B"
  end
end

class BlackQueen < Queen
  def initialize(location = nil)
    super
    @color = 'B'
    @ucode = "\u2655"
  end
end

class King < Piece
  attr_accessor :moved

  def initialize(location = nil)
    @moved = false
    super
  end

  def possible_moves(board)
    file, rank = loc_to_coord(@location)
    result = []
    result << coord_to_loc(file + 1, rank) if board.valid_and_empty?(file + 1, rank)
    result << coord_to_loc(file + 1, rank - 1) if board.valid_and_empty?(file + 1, rank - 1)
    result << coord_to_loc(file, rank - 1) if board.valid_and_empty?(file, rank - 1)
    result << coord_to_loc(file - 1, rank - 1) if board.valid_and_empty?(file - 1, rank - 1)
    result << coord_to_loc(file - 1, rank) if board.valid_and_empty?(file - 1, rank)
    result << coord_to_loc(file - 1, rank + 1) if board.valid_and_empty?(file - 1, rank + 1)
    result << coord_to_loc(file, rank + 1) if board.valid_and_empty?(file, rank + 1)
    result << coord_to_loc(file + 1, rank + 1) if board.valid_and_empty?(file + 1, rank + 1)
    result
  end

  def possible_captures(board)
    file, rank = loc_to_coord(@location)
    result = []
    result << coord_to_loc(file + 1, rank) if board.valid_and_enemy?(file + 1, rank, @color)
    result << coord_to_loc(file + 1, rank - 1) if board.valid_and_enemy?(file + 1, rank - 1, @color)
    result << coord_to_loc(file, rank - 1) if board.valid_and_enemy?(file, rank - 1, @color)
    result << coord_to_loc(file - 1, rank - 1) if board.valid_and_enemy?(file - 1, rank - 1, @color)
    result << coord_to_loc(file - 1, rank) if board.valid_and_enemy?(file - 1, rank, @color)
    result << coord_to_loc(file - 1, rank + 1) if board.valid_and_enemy?(file - 1, rank + 1, @color)
    result << coord_to_loc(file, rank + 1) if board.valid_and_enemy?(file, rank + 1, @color)
    result << coord_to_loc(file + 1, rank + 1) if board.valid_and_enemy?(file + 1, rank + 1, @color)
    result
  end

  def to_json(*)
    JSON.dump({
                type: self.class,
                moved: @moved
              })
  end
end

class WhiteKing < King
  def initialize(location = nil)
    super
    @color = 'W'
    @ucode = "\u265A"
  end
end

class BlackKing < King
  def initialize(location = nil)
    super
    @color = 'B'
    @ucode = "\u2654"
  end
end
