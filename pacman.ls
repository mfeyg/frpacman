{zip-with, sum, keys, values, obj-to-pairs, empty, filter} = require("prelude-ls")
# require! numeric

draw-from = (dist) ->
    go = (x,[[l,p],...r]) -> if x < p or empty r then l else go x - p, r
    go Math.random! * sum(values dist), obj-to-pairs dist

random-path = (length, dist) -> [draw-from dist for til length]

Cantor =    # pairing functions (just for fun?)
    pair: (x,y) -> y + (x + y) * (x + y + 1) / 2
    unordered-pair: (x,y) -> (x <? y) + div (x + y + 1) ** 2 , 4





################################################################################

maybe = (v,f) -> if v? then f v

interval = (a,b) ->
    | a <= b and a is not Infinity and b is not -Infinity
      => {a,b}

shift = (i,x) -> i{a,b} += {a:x,b:x} ; i

intersect = (i1,i2) -> interval i1.a >? i2.a, i1.b <? i2.b

when-intersect = (^^i1, ^^i2) ->    # the time-interval of intersection
                                    # of two moving intervals
    # shift to present
    [i1, i2] = [i2, i1] if i1.t > i2.t
    shift i1, i1.v * (i2.t - i1.t) if i1.t < i2.t
    t0 = i2.t

    # get relative velocity
    [i1,i2] = [i2,i1] if i1.v < i2.v
    v = i1.v - i2.v

    interval (i2.a - i1.b) / v + t0, (i2.b - i1.a) / v + t0

horizontal-proj = ({left,right,v:[dx]}:o) -> o with {a:left, b:right, v:dx}
vertical-proj = ({top,bottom,v:[,dy]}:o) -> o with {a: top, b:bottom, v:dy}

collision = (o1,o2) ->
    ht <- maybe when-intersect horizontal-proj(o1), horizontal-proj(o2)
    vt <- maybe when-intersect vertical-proj(o1), vertical-proj(o2)
    t <- maybe intersect ht,vt
    t.a


################################################################################


