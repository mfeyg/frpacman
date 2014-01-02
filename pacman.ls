draw = (probs) ->
	go = (x,[[l,p],...r]) -> if x < p or empty r then l else go x - p, r
	go Math.random! * sum(values probs), obj-to-pairs probs

random-path = (length, probs) -> [draw probs for til length]

vec-add = zip-with (+)

class Grid
	(@width, @height) -> @walls = [0 for til @width * @height * 2]
	of: (^^[x,y],[dx,dy]) ->
		pos = [(x + dx) %% @width, (y + dy) %% @height]
		if dx + dy > 0 then [x,y] = pos
		i = 2 * (x + y * @width)
		++i if dy
		walls = @walls
		pos: pos
		wall:~
			-> walls[i]
			(walls[i]) ->

class Maze
	(@width, @height) ->
		@path = random-path width * height, {left: 1, right: 5, straight: 20}
		@grid = [[[] for til height] for til width]
		pos = Vec(0,0)
		v = Vec(0,1)
		right = (v) -> Vec(v.y,-v.x)
		path = map ({straigh: id, right, left: (.neg) . right}.), @path
		for turn in path
			voic