{empty, map, zip-with, apply} = require \prelude-ls

maybe = (v,f) --> f v if v?

interval = (a,b) ->
    | a <= b and a is not Infinity and b is not -Infinity
      => {a,b}

len = (i) -> if i then i.b - i.a else 0

rectangle = (...intervals) -> map (apply interval), intervals

velocity = map (.v)

stop = (with map (with v:0), it)

set-velocity = (rect, v) ->
    rect with (zip-with (i, v) -> i with {v}) rect, v

intersection = (i1,i2) --> interval i1.a >? i2.a, i1.b <? i2.b

when-intersect = (i1, i2) ->    # the time-interval of intersection
                                # of two moving intervals
    [i1,i2] = [i2,i1] if i1.v < i2.v
    v = i1.v - i2.v

    interval (i2.a - i1.b) / v, (i2.b - i1.a) / v

shift-by = (i, t) ->
    i with a: i.a + i.v * t, b: i.b + i.v * t

at = (rect, time) ->
    rect with (if rect.time? => map (`shift-by` time - rect.time), rect) <<< {time}

collision-interval = (rect1, rect2) ->
    go = ([i,...i-s], [j,...js]) ->
     | empty i-s and empty js =>
        when-intersect i, j
     | i? and j? =>
        I <- maybe when-intersect i,j
        L <- maybe go i-s, js
        intersection I, L
    go rect1, rect2 `at` rect1.time

module.exports = {interval, len, intersection, shift-by,  rectangle, at, velocity, stop, set-velocity, collision-interval}