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
end

class WhitePawn < Piece
  def initialize(location)
    super
    @color = 'W'
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
end

class BlackPawn < Piece
  def initialize(location)
    super
    @color = 'B'
  end
  def possible_moves(board)
    result = []
    file, rank = loc_to_coord(@location)
    result << coord_to_loc(file, rank - 1) if board.valid_and_empty?(file, rank - 1)
    result << coord_to_loc(file, rank - 2) if rank == 1 && board.empty?(file, rank - 1) && board.empty?(file, rank - 2)
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
  def initialize(location)
    super
    @color = 'W'
  end
end

class BlackKnight < Knight
  def initialize(location)
    super
    @color = 'B'
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
  def initialize(location)
    super
    @color = 'W'
  end
end

class BlackBishop < Bishop
  def initialize(location)
    super
    @color = 'B'
  end
end

class Rook < Piece
  def possible_moves(board)
    straight_moves(board)
  end
  def possible_captures(board)
    straight_captures(board)
  end
end

class WhiteRook < Rook
  def initialize(location)
    super
    @color = 'W'
  end
end

class BlackRook < Rook
  def initialize(location)
    super
    @color = 'B'
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
  def initialize(location)
    super
    @color = 'W'
  end
end

class BlackQueen < Queen
  def initialize(location)
    super
    @color = 'B'
  end
end

class King < Piece
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
end

class WhiteKing < King
  def initialize(location)
    super
    @color = 'W'
  end
end

class BlackKing < King
  def initialize(location)
    super
    @color = 'B'
  end
end
