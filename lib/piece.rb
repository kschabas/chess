#frozen_string_literal :true

class Piece
  attr_accessor :location, :color, :name

  def initialize(name, color, location)
    @location = location
    @color = color
    @name = name
  end

end

class Pawn < Piece
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