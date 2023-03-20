# frozen_string_literal: true

# Board class
class Board
  include Location
  DIM = 8
  attr_accessor :grid

  def initialize
    @grid = Array.new(DIM) { Array.new(DIM, nil) }
  end

  def clear_board
    @grid.each_index { |row| @grid[row].each_index { |col| @grid[row][col] = nil } }
  end

  def empty?(file, rank)
    @grid[rank][file].nil?
  end

  def valid_square?(file, rank)
    file.between?(0, DIM - 1) && rank.between?(0, DIM - 1)
  end

  def valid_and_empty?(file, rank)
    valid_square?(file, rank) && empty?(file, rank)
  end

  def valid_and_enemy?(file, rank, color)
    valid_square?(file, rank) && enemy_piece?(file, rank, color)
  end

  def enemy_piece?(file, rank, color)
    return false if @grid[rank][file].nil?
    return false if @grid[rank][file].color == color

    true
  end

  def add_piece(piece, location)
    file, rank = loc_to_coord(location)
    grid[rank][file] = piece
  end

  def remove_piece(location)
    file, rank = loc_to_coord(location)
    grid[rank][file] = nil
  end
end
