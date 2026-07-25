extends Microgame
class_name AstronautTetris

const FLIGHT_DURATION = 4.75
const DESCENT_DURATION = 2.0
const SIT_DURATION = 1.0

enum DIRECTION { LEFT, DOWN, NONE }

var movement_direction: DIRECTION = DIRECTION.NONE
var flight_speed: float = 500
var astro_tween: Tween
var victory_texture: Texture2D

func _ready() -> void:
	victory_texture = preload("res://assets/textures/astronaut_in_chair_placeholder.png")
	super()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if astronaut_out_of_bounds():
		lose()
		
	if !playing:
		return

	if Input.is_action_just_pressed("down") || Input.is_action_just_pressed("action"):
		movement_direction = DIRECTION.DOWN
		
	move_astronaut(delta)

func move_astronaut(delta) -> void:
	var movement_vector: Vector2
	match movement_direction:
		DIRECTION.NONE:
			return
		DIRECTION.LEFT:
			movement_vector = Vector2(1, 0)
		DIRECTION.DOWN:
			movement_vector = Vector2(0, 1)
	$Astronaut.position += movement_vector * flight_speed * delta
	

func start_astronaut_movement() -> void:
	$Astronaut.show()
	movement_direction = DIRECTION.LEFT


func _on_chair_area_entered(area: Area2D) -> void:
	if !playing:
		return
	
	$Timer.stop()
	movement_direction = DIRECTION.NONE
	$Astronaut.hide()
	$Chair/ChairSprite.texture = victory_texture
	win()
	
func begin() -> void:
	$Astronaut.hide()
	super()
	
func _on_prompt_timer_timeout() -> void:
	start_astronaut_movement()
	flight_speed = get_viewport_rect().size.x / 3.5
	$PromptTimer.stop()

func astronaut_out_of_bounds() -> bool:
	return $Astronaut.position.x >= get_viewport_rect().size.x || $Astronaut.position.y >= get_viewport_rect().size.y
