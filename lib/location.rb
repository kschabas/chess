# frozen_string_literal: true

# Module to deal with chess coords to array index conversions
module Location
  def loc_to_coord(loc)
    [loc[0].ord - 'a'.ord, loc[1].ord - '1'.ord]
  end

  def coord_to_loc(file, rank)
    "#{(file + 'a'.ord).chr}#{(rank + '1'.ord).chr}"
  end

  def enemy_color(color)
    if color == 'W'
      'B'
    else
      'W'
    end
  end
end
