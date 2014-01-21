global <<< require \prelude-ls
require! {
  Bacon: baconjs
  multimethod
  Heap
  "./commutative-multimethod"
  "./Geometry"
}

{stop, velocity, set-velocity, rectangle, interval, len, intersection, at, shift-by, collision-interval} = Geometry

draw-from = (dist) ->
    go = (x,[[l,p],...r]) -> if x < p or empty r then l else go x - p, r
    go Math.random! * sum(values dist), obj-to-pairs dist

own = (obj) ->
  | typeof obj == \object => [] <<< {[k, own v] for k,v of obj}
  | otherwise => obj

print = console.log . own

maybe = (v,f) --> f v if v?

compare = (a,b) -->
  | a < b => -1
  | a > b => 1
  | a == b => 0

compare-by = (f,a,b) --> compare f(a), f(b)







# (Object, Object) -> [Object]
break-at = (obj, wall) ->
  h = intersection wall.0, obj.0
  v = intersection wall.1, obj.1
  i = if len(h) < len(v) then 1 else 0
  first-half = ^^wall
  second-half = ^^wall
  first-half[i] = (interval wall[i]a, obj[i]a) <<< v: wall[i]v
  second-half[i] = interval obj[i]b, wall[i]b <<< v: wall[i]v
  filter (.[i]?), [first-half, second-half]


# (Object,Object) -> [Object]
collision = commutative-multimethod (.type)
  .default id
  .when \wall \pacman (wall, pacman) ->
    [wall, stop pacman]
  .when \wall \ghost (wall, ghost) ->
    [wall, stop ghost]
  .when \wall \roller (wall, roller) ->
    break-at(roller, wall) ++ roller
  .when \pacman \ghost (pacman, ghost) ->
    [pacman with {+dead}, ghost]

# Board -> Maybe Board
next-collision = (board) ->
  time = Infinity
  for ,i in board then for j til i
    I = collision-interval board[i], board[j]
    if I? and board.time <= I.a < time
      [ii,jj] = [i,j]
      time = I.a
  if ii?
    (board[til jj] ++ board[jj+1 til ii] ++ board[ii+1 til] \
      ++ collision board[ii], board[jj]) <<< {time}

# Event -> Board -> Board
outcome = (event, board) -->
  board = switch event.type
  case \add
    board ++ (event.obj with time: event.time)
  else ^^board
  board <<< time: event.time

# Heap Event
events = new Heap compare-by (.time)

# Action = Board -> (Time, ->Board)

step = (board) ->
  if true and roller = find (.type == \roller), board
    console.log roller[0].a, roller[1].a
    console.log velocity roller
    console.log roller.time
  time = Infinity
  if not events.empty!
    time = events.top!time
    next = -> outcome events.pop!, board
  col = next-collision board
  if col? and col.time <= time
    time = col.time
    next = -> col
  for obj,i in board
    action = obj.action board if obj.action?
    if action? and action.time <= time
      time = action.time
      next = -> (map (`at` time), board) with (i): action!, time: action.time
      #console.log time
  next

board = []
take-step = ->
  s = step board
  if s?
    board := s[1]!
    print board
  else
    console.log "That's it"
    if board.done then board := []
    board.done := true
  board

result = (board) ->
  s = step board
  if s? then result s! else board

create = (type, x-span, y-span, v = [0 0]) ->
  rectangle x-span, y-span
  |> set-velocity _, v
  |> (<<< {type})



roller = (create \roller [0 1] [0 1] [0 1]) <<<
  action: (board) ->
    if board.time < 10
      time = 2 + 2 * floor board.time/2
      roller = this
      (<<< {time}) <| ->
        roll = +draw-from 0: 20, 1: 7, 2: 1, 3: 4
        v = velocity roller
        for til roll
          v = [-v.1, v.0]
        #console.log v.0, v.1
        set-velocity roller `at` time, v


grid = [create \wall [i,i] [0 10] for i from 0 to 10] ++ [create \wall [0 10] [i,i] for i from 0 to 10]

do prime = ->
  for obj in grid ++ roller
    events.push do
      time: 0
      type: \add
      obj: obj

#print result []

if require(\repl).start?
  require \repl .start input: process.stdin, output: process.stdout
  .context <<< {events,step,take-step,print,own,velocity,set-velocity,next-collision,prime,result}

window <<< {result} if window?




























