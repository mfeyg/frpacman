draw = (probs) ->
	go = (x,[[l,p],...r]) -> if x < p or empty r then l else go x - p, r
	go Math.random! * sum(values probs), obj-to-pairs probs

random-path = (length, probs) -> [draw probs for til length]

class Vec
	(...@els) ~>
	plus: (zip-with (+), @els) . (.els)
	neg:~ -> Vec.apply null, (map negate, @els)
	for let k, i of {x: 0, y: 1, z: 2, w: 3}
		Object.define-property @prototype, k, do
			get: -> @els[i]
			set: (@els[i]) ->

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