class Thing
  ({@type, position, x = position?x, y = position?y, \
    left = x, top = y, w, h, width = w, height = h, right = left + width, \
    bottom = top + height, velocity, v = velocity, dx = v?0, dy = v?1, \
    @update}) ->

    @0 = interval left, right
    @1 = interval top, bottom
    @0.v = dx or 0
    @1.v = dy or 0
    @length = 2

# class Scence then (@time, ...things) -> @things = map (with {@time}) things

class Steamroller extends Thing
  ->
    super ...
    do @init = (start = 0, end = 100) ->
    | start >= end
      @0.v = @1.v = 0
      @dead = true
    | otherwise
      
      @changes-at = start + 2
      @changes-to = ^^this
    delete @init


class Field
  -> @time = -Infinity; @changes-at = Infinity; @things = []
