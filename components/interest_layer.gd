extends Node2D

## variable to affect randomness, higher is wider range of possibilities for shapes/grid
var VARIANCE := 300.0

var colors = [
	{"color": Color8(10, 10, 10), "dark":true},    ## black, 050609, DARK
	{"color": Color8(247, 226, 143), "dark":true},  ## yellow, F7E28F, LIGHT
	{"color": Color8(60, 119, 155), "dark":true},   ## blue, 3C779B, DARK
	{"color": Color8(163, 151, 171), "dark":true},  ## purple, A397AB, LIGHT
	{"color": Color8(176, 70, 78), "dark":true},    ## red, B0464E, DARK
	{"color": Color8(244, 158, 55), "dark":true},   ## orange, F49E37, DARK
	{"color": Color8(245, 245, 245), "dark":true}  ## white, F0F0F0, LIGHT
]

## again quick and dirty, because I do't want to deal with searching arrays, no 0 or 6 because we want color, not black and white
var light_colors = [1, 3]
var dark_colors = [2, 4, 5]

var bg_color_index := 0
var bg_is_dark := true

var screen_size
var WIDTH
var HEIGHT

func _ready() -> void:

	create_interest_layer()

func _draw() -> void:
	## this is probably where you would select background png, and display it

	if randf() > 0.5:
		draw_shapes()
	else:
		draw_grid()


func create_interest_layer()-> void:
	randomize()
	
	screen_size = get_viewport_rect().size
	WIDTH = screen_size.x
	HEIGHT = screen_size.y
	
	VARIANCE = min(WIDTH/6, HEIGHT/3)
	
	bg_color_index = randi() % colors.size()
	bg_is_dark = colors[bg_color_index].dark
	
	queue_redraw()


## SHAPES

func draw_shapes() -> void:

	## select number of shapes to draw
	var num_shapes = randi_range(3, 5)

	## choose a point for the shapes to cluster around. y is static because if we have any variation, shapes go off screen
	var cluster_x = randf_range(VARIANCE * 2.0, WIDTH - VARIANCE * 2.0)
	var cluster_y = HEIGHT / 2.0

	var size = randf_range(VARIANCE/4, VARIANCE/2)

	## our arcs should be the same thickness, setting here for consistency among all arcs
	var arc_width = randi_range(10, 20)   

	for i in num_shapes:

		## select a color that is not the background color, and if bg is light, make sure we select dark, and if bg is dark, ensure we select light
		var shape_color = colors[select_color()]['color']
		
		## with 60% opacity
		shape_color.a = 0.6

		var which_shape = randf()

		## give random variance around cluster position to not stack shapes
		var x_off = randf_range(-VARIANCE, VARIANCE)
		var y_off = randf_range(-VARIANCE, VARIANCE)

		var pos = Vector2(
			cluster_x + x_off,
			cluster_y + y_off
		)

		## 10% chance for arcs
		if which_shape > 0.9:

			
			## limit direction of arc to up/down/left/right
			var start_angle = (randi() % 4 ) * PI/2.0

			draw_arc(pos, size*0.5, start_angle, start_angle+PI, 32, shape_color, arc_width)

		## 10% chance for plus
		elif which_shape > 0.8:
			## plusses are kinda stupid because we have to draw each vertex
			## we cant just draw two rects because the transparency would overlap in the middle :(
			## no random rotation for these, I dont have hours to spend figuring that out. it's ok, they are rare anyway

			var points = PackedVector2Array([
				pos + Vector2(-size, -size*0.1),
				pos + Vector2(-size*0.1, -size*0.1),
				pos + Vector2(-size*0.1, -size),
				pos + Vector2(size*0.1, -size),
				pos + Vector2(size*0.1, -size*0.1),
				pos + Vector2(size, -size*0.1),
				pos + Vector2(size, size*0.1),
				pos + Vector2(size*0.1, size*0.1),
				pos + Vector2(size*0.1, size),
				pos + Vector2(-size*0.1, size),
				pos + Vector2(-size*0.1, size*0.1),
				pos + Vector2(-size, size*0.1),
			])

			draw_polygon(points, PackedColorArray([shape_color]))

		## 20%
		elif which_shape > 0.6:

			## get angle to rotate to form equilateral triangle
			var angle = TAU / 3.0
			
			## offset rotation so we are pointing either straight up or straight down (though in processing the 0 angle starts at the 3o'clock position, this will need to change if 0 angle is different for godot)
			var rot = PI / 2.0 
			if randi() % 2 == 1:
				rot += PI

			var points = PackedVector2Array([
				pos + Vector2(cos(rot), sin(rot)) * size,
				pos + Vector2(cos(rot + angle), sin(rot + angle)) * size,
				pos + Vector2(cos(rot + (angle*2.0)), sin(rot + (angle*2.0))) * size
			])

			draw_polygon(points, PackedColorArray([shape_color]))

		## 20% chance for a circle
		elif which_shape > 0.4:

			size = randf_range(VARIANCE/3, VARIANCE)
			draw_circle(pos, size * 0.5, shape_color)

		## 20% chance for rectangle
		elif which_shape > 0.2:

			## set size for short side and long side
			var short_side = randf_range(VARIANCE/6, VARIANCE/2)
			var long_side = randf_range(VARIANCE/2, VARIANCE)

			var w
			var h

			var r = randf()

			## vertical rect
			if r > 0.6:
				w = short_side
				h = long_side

			## horizontal rect
			elif r > 0.2:
				w = long_side
				h = short_side

			## small chance for square
			else:
				w = short_side
				h = short_side

			draw_rect(
				Rect2(
					pos - Vector2(w * 0.5, h * 0.5),
					Vector2(w, h)
				),
				shape_color,
				true
			)


## GRID

func draw_grid() -> void:

	var grid_ratio = randf()
	var orientation = randf()

	## need to give a minimum so we don't gave grid of size 0
	var grid_size = 80 + randf() * VARIANCE

	var larger
	var smaller

	## 1:5 grid
	if grid_ratio > 0.7:
		larger = grid_size
		smaller = grid_size / 5.0

	## 1:3 grid
	elif grid_ratio > 0.4:
		larger = grid_size
		smaller = grid_size / 3.0

	## 1:1 grid
	else:
		larger = grid_size
		smaller = grid_size

	var grid_color = colors[select_color()]['color']
	grid_color.a = 0.6

	var thickness = randi_range(2, 5)

	## vertical grid
	if orientation > 0.5:
		var x = 0.0
		while x <= WIDTH:

			draw_line(
				Vector2(x, 0),
				Vector2(x, HEIGHT),
				grid_color,
				thickness
			)

			x += smaller

		var y = 0.0
		while y <= HEIGHT:

			draw_line(
				Vector2(0, y),
				Vector2(WIDTH, y),
				grid_color,
				thickness
			)

			y += larger

	## horizontal grid
	else:

		var x = 0.0
		while x <= WIDTH:

			draw_line(
				Vector2(x, 0),
				Vector2(x, HEIGHT),
				grid_color,
				thickness
			)

			x += larger

		var y = 0.0
		while y <= HEIGHT:

			draw_line(
				Vector2(0, y),
				Vector2(WIDTH, y),
				grid_color,
				thickness
			)

			y += smaller



func select_color() -> int:

	if bg_is_dark:
		return light_colors.pick_random()

	return dark_colors.pick_random()
