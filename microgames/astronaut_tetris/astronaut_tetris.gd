extends Microgame
class_name AstronautTetris

const FLIGHT_DURATION = 4.75
const DESCENT_DURATION = 2.0
const SIT_DURATION = 1.0
const SPAWN_DELAY = 0.80
const ASTRONAUT_TEXTURE_PATH = "res://assets/textures/astronaut_tetris/astro-sit.png"
const POOL_TEXTURE_PATHS = [
	ASTRONAUT_TEXTURE_PATH,
	"res://assets/textures/astronaut_tetris/monke.png",
	"res://assets/textures/dog_halftone.png"
]

enum DIRECTION { LEFT, DOWN, NONE }

var movement_direction: DIRECTION = DIRECTION.LEFT
var flight_speed: float = 500
var astro_tween: Tween
var victory_texture: Texture2D
var entity_scene: PackedScene
var entity_textures: Dictionary[String, Texture2D] = {}
var current_entity
var is_correct: bool = false

func _ready() -> void:
	preload_resources()
	super()

func preload_resources() -> void:
	victory_texture = preload("res://assets/textures/astronaut_tetris/astro-sit-inchair.png")
	entity_scene = preload("res://entities/tetris_mover.tscn")
	for path in POOL_TEXTURE_PATHS:
		entity_textures[path] = load(path)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !playing:
		return

	if Input.is_action_just_pressed("down") || Input.is_action_just_pressed("action"):
		movement_direction = DIRECTION.DOWN
		
	if current_entity != null:
		move_entity(delta)
	
func move_entity(delta) -> void:
	var movement_vector: Vector2
	match movement_direction:
		DIRECTION.NONE:
			return
		DIRECTION.LEFT:
			movement_vector = Vector2(1, 0)
		DIRECTION.DOWN:
			movement_vector = Vector2(0, 1)
	current_entity.position += movement_vector * flight_speed * delta
	if entity_out_of_bounds():
		current_entity.free()
		if is_correct:
			lose()
			return
		else:
			spawn_entity()
	

func start_astronaut_movement() -> void:
	$Astronaut.show()
	movement_direction = DIRECTION.LEFT


func _on_chair_area_entered(area: Area2D) -> void:
	if !playing:
		return
	
	$Timer.stop()
	movement_direction = DIRECTION.NONE
	current_entity.hide()
	if is_correct:
		$Chair/ChairSprite.texture = victory_texture
		win()
	else:
		lose()
	
func begin() -> void:
	super()
	
func _on_prompt_timer_timeout() -> void:
	flight_speed = get_viewport_rect().size.x * entity_textures.size() / ($Timer.wait_time - $PromptTimer.wait_time - 0.25)
	$PromptTimer.stop()
	spawn_entity()

func spawn_entity() -> void:
	if entity_textures.size() == 0:
		lose()
		return
	
	var entity = entity_scene.instantiate()
	entity.position = $EntitySpawner.position
	current_entity = entity
	var texture_result = random_entity_texture()
	entity.set_texture(texture_result[1])
	entity.show()
	movement_direction = DIRECTION.LEFT
	is_correct = texture_result[0] == ASTRONAUT_TEXTURE_PATH
	add_child(entity)

func random_entity_texture() -> Array:
	var size = entity_textures.size()
	var random_key = entity_textures.keys()[randi() % size]
	var texture = entity_textures[random_key]
	entity_textures.erase(random_key)
	return [random_key, texture]
	
func entity_out_of_bounds() -> bool:
	if current_entity == null:
		return false
		
	return current_entity.position.x >= get_viewport_rect().size.x || current_entity.position.y >= get_viewport_rect().size.y
