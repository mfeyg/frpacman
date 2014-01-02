"use strict";

var Pacman = function() {

	function Rect(x, y, w, h) {this.x = x; this.y = y; this.w = w; this.h = h;}
	function Vec(x,y) {this.x = x; this.y = y;}
	Rect.prototype.move = function(vec) { this.x += vec.x; this.y += vec.y; }
	var Dir = {right: Vec(1,0), down: Vec(0,1), left: Vec(-1,0), up: Vec(0,-1)};
	

	function designMaze(width, height) {

	}

	function Board(width, height) {
		this.width = width;
		this.height = height;

	}

}();