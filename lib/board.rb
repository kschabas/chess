#frozen_string_literal: true

#Board class
class Board
  DIM = 8
  attr_accessor :grid
  def initialize
    @grid = Array.new(DIM) { Array.new(DIM, nil) }
  end

  def clear_board
    @grid.each_index { |row| @grid[row].each_index { |col| @grid[row][col] = nil } }
  end

  def empty?(file, rank)
    return @grid[rank][file].nil?
  end

  def valid_square?(file, rank)
    return file.between?(0, DIM - 1) && rank.between?(0, DIM - 1)
  end

  def enemy_piece?(file, rank, color)
    return false if @grid[rank][file].nil?
    return false if @grid[rank][file].color == color
    true
  end
end