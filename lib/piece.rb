# frozen_string_literal: true

require './lib/location'

# class to implement chess pieces
class Piece
  include Location
  attr_accessor :location, :color, :name

  def initialize(name, color, location)
    @location = location
    @color = color
    @name = name
  end
end

class Pawn < Piece
  def valid_move?(dest_loc, capture, color)
    possible_moves = []
    file, rank = loc_to_coord(@location)
    if !capture && color == 'W'
      possible_moves << coord_to_loc(file, rank + 1)
      possible_moves << coord_to_loc(file, rank + 2) if rank == 2
    elsif !capture && color == 'B"'
      possible_moves << coord_to_loc(file, rank - 1)
      possible_moves << coord_to_loc(file, rank - 2) if rank == 7
    elsif capture && color == 'W'
      possible_moves << coord_to_loc(file + 1, rank + 1)
      possible_moves << coord_to_loc(file - 1, rank + 1)
    else
      possible_moves << coord_to_loc(file + 1, rank - 1)
      possible_moves << coord_to_loc(file - 1, rank - 1)
    end
    possible_moves.include?(dest_loc)
  end
end

class Knight < Piece
end

class Bishop < Piece
end

class Rook < Piece
end

class Queen < Piece
end

class King < Piece
end