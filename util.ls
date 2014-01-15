draw-from = (dist) ->
    go = (x,[[l,p],...r]) -> if x < p or empty r then l else go x - p, r
    go Math.random! * sum(values dist), obj-to-pairs dist

random-path = (length, dist) -> [draw-from dist for til length]

Cantor =    # pairing functions (just for fun?)
    pair: (x,y) -> y + (x + y) * (x + y + 1) / 2
    unordered-pair: (x,y) -> (x <? y) + div (x + y + 1) ** 2 , 4