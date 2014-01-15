global <<< require \prelude-ls
require! {
  Bacon: baconjs
  multimethod
  "./commutative-multimethod"
  "./Geometry"
}

{stop, set-velocity, rectangle, interval, at, shift-by, collision-interval} = Geometry

own = (obj) ->
  | typeof obj == \object => [] <<< {[k, own v] for k,v of obj}
  | otherwise => obj

print = console.log . own





collision = commutative-multimethod (.type)
  .default id
  .when \wall, \pacman, (wall, pacman) ->
    [wall, stop pacman]
  .when \wall, \ghost, (wall, ghost) ->
    [wall, stop ghost]
  .when \wall, \steamroller, (wall, roller) ->
    break-wall(wall, roller) ++ roller
  .when \pacman, \ghost, (pacman, ghost) ->
    [pacman with {+dead}, ghost]

maybe = (v,f) --> f v if v?

next = (board) ->
  collide = ([r,s,...rs]) -> collision(r,s) ++ rs
  go = (head, [r,s,...rs], time) -> | r? and s? =>
    [res,time]? = do
      i <- maybe collision-interval r,s
      t = i.a
      if board.time - 1e-9 < t < time then
        [collide map (`at` t), [r,s,...rs]; t]
    [res,time]? = go [r], [s,...rs], time
    [res,time]? = go [s], [r,...rs], time
    if res? => [head ++ res; time]
  [board,time]? = go [], board, Infinity
  if time? then board <<< {time}

evolution = (board) ->
  if board? then Bacon.once board .concat evolution next board
  else Bacon.never!

events = new Bacon.Bus

board =
  do
    evs <- events.sliding-window(2,1).flat-map
    time = evs.1?time ? Infinity
    board
      .take 1
      .map (action evs.0)
      .flat-map evolution
      .take-while (.time < time)
  .to-property []

action = (ev, board) -->
  board = map (`at` ev.time) board
  switch ev.type
  case \add
    ev.obj{time} = ev
    board ++= ev.obj
  board{time} = ev
  return board

board.log!

create = (type, x-span, y-span, v = [0 0]) ->
  rectangle x-span, y-span
  |> set-velocity _, v
  |> (<<< {type})

events.push do
  time: 0
  type: \add
  obj: create \pacman [0 1] [0 1] [1 0]

































################################################################################




################################################################################



# events = new Bacon.Bus
# board = Bacon.Model []

# collisions = board.map (board) ->
#     collide = (x,y) ->
#         t <- maybe time-of-collision x,y
#         {x,y,t}
#     compact [collide board[i], board[j] for ,i in board for j til i]

# board.apply events.map (e) -> switch e.type
#     | \add => (board) -> board ++ e.obj

# #board.log!
# #collisions.log!

# events.push type: \add, obj: left: 0, right: 1, top: 0, bottom: 1, t: 0, v: [1,0], name: \bob
# events.push type: \add, obj: left: 2, right: 3, top: 0, bottom: 1, t: 0, v: [0,0],  name: \george

# board.add-wall = (start, len, dir) ->
#     start<[x y]> = start
#     end = ^^start
#     end[dir] += len
#     wall =
#         left: start.x
#         right: end.x
#         top: start.y
#         bottom: end.y
#         v: [0 0]
#         t: 0
#         type: \wall
#     wall.split-at = (a,b) ~>
#         @modify reject (== wall)
#         @add-wall start, start[dir] + len - a, dir
#         start2 = ^^start
#         start2[dir] += b
#         @add-wall start2, start[dir] - b, dir
#     @modify (++ wall)

# board.add-wall [1 0], 10, \y
# board.add-wall [0 1], 10, \x

# next-collision = collisions.map ((fold ((a,b) -> if a.t < b.t then a else b), {t:Infinity}) . filter ((>=0) . (.t)))

# commutative-multimethod = (f = id) ->
#     mm = multimethod (a,b) -> [f(a), f(b)]
#     [_dispatch,_when] = mm<[dispatch when]>
#     mm.dispatch = (f) -> _dispatch (a,b) -> [f(a), f(b)]
#     mm.when = (a,b,f) ->
#         _when [a,b], f
#         _when [b,a], (b,a) -> f a,b
#     mm

# collision = commutative-multimethod (.type)
# collision.when void, \wall, (obj, wall) ->
#     if obj.v.0 then wall.split-at obj.left, obj.right
#     else wall.split-at obj.top, obj.bottom

# next-collision = next-collision.map ({x,y}) -> collision x, y

# board.apply next-collision.map (f) -> (board) -> f; board