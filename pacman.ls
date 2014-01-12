global <<< require \prelude-ls
require! {
    Heap: heap
    Bacon: "bacon.model"
    multimethod
}


draw-from = (dist) ->
    go = (x,[[l,p],...r]) -> if x < p or empty r then l else go x - p, r
    go Math.random! * sum(values dist), obj-to-pairs dist

random-path = (length, dist) -> [draw-from dist for til length]

Cantor =    # pairing functions (just for fun?)
    pair: (x,y) -> y + (x + y) * (x + y + 1) / 2
    unordered-pair: (x,y) -> (x <? y) + div (x + y + 1) ** 2 , 4





################################################################################

maybe = (v,f) -> f v if v?

interval = (a,b) ->
    | a <= b and a is not Infinity and b is not -Infinity
      => {a,b}

shift = (i, x) -> i
    ..a += x
    ..b += x

intersect = (i1,i2) -> interval i1.a >? i2.a, i1.b <? i2.b

when-intersect = (^^i1, ^^i2) ->    # the time-interval of intersection
                                    # of two moving intervals
    # shift to present
    [i1, i2] = [i2, i1] if i1.t > i2.t
    shift i1, i1.v * (i2.t - i1.t) if i1.t < i2.t
    t0 = i2.t

    # get (positive) relative velocity
    [i1,i2] = [i2,i1] if i1.v < i2.v
    v = i1.v - i2.v

    interval (i2.a - i1.b) / v + t0, (i2.b - i1.a) / v + t0

horizontal-proj = ({left,right,v:[dx]}:o) -> o with {a:left, b:right, v:dx}
vertical-proj = ({top,bottom,v:[,dy]}:o) -> o with {a: top, b:bottom, v:dy}

time-of-collision = (o1,o2) ->
    hx <- maybe when-intersect horizontal-proj(o1), horizontal-proj(o2)
    vx <- maybe when-intersect vertical-proj(o1), vertical-proj(o2)
    x <- maybe intersect hx,vx
    x.a


################################################################################



events = new Bacon.Bus
board = Bacon.Model []

collisions = board.map (board) ->
    collide = (x,y) ->
        t <- maybe time-of-collision x,y
        {x,y,t}
    compact [collide board[i], board[j] for ,i in board for j til i]

board.apply events.map (e) -> switch e.type
    | \add => (board) -> board ++ e.obj

#board.log!
#collisions.log!

events.push type: \add, obj: left: 0, right: 1, top: 0, bottom: 1, t: 0, v: [1,0], name: \bob
events.push type: \add, obj: left: 2, right: 3, top: 0, bottom: 1, t: 0, v: [0,0],  name: \george

board.add-wall = (start, len, dir) ->
    start<[x y]> = start
    end = ^^start
    end[dir] += len
    wall =
        left: start.x
        right: end.x
        top: start.y
        bottom: end.y
        v: [0 0]
        t: 0
        type: \wall
    wall.split-at = (a,b) ~>
        @modify reject (== wall)
        @add-wall start, start[dir] + len - a, dir
        start2 = ^^start
        start2[dir] += b
        @add-wall start2, start[dir] - b, dir
    @modify (++ wall)

board.add-wall [1 0], 10, \y
board.add-wall [0 1], 10, \x

next-collision = collisions.map ((fold ((a,b) -> if a.t < b.t then a else b), {t:Infinity}) . filter ((>=0) . (.t)))

commutative-multimethod = (f = id) ->
    mm = multimethod (a,b) -> [f(a), f(b)]
    [_dispatch,_when] = mm<[dispatch when]>
    mm.dispatch = (f) -> _dispatch (a,b) -> [f(a), f(b)]
    mm.when = (a,b,f) ->
        _when [a,b], f
        _when [b,a], (b,a) -> f a,b
    mm

collision = commutative-multimethod (.type)
collision.when void, \wall, (obj, wall) ->
    if obj.v.0 then wall.split-at obj.left, obj.right
    else wall.split-at obj.top, obj.bottom

next-collision = next-collision.map ({x,y}) -> collision x, y

board.apply next-collision.map (f) -> (board) -> f; board

collisions.log!
board.log!