extends Microgame
class_name AstronautTetris

const ASTRONAUT_TEXTURE_PATH = "res://assets/textures/astronaut_tetris/astro-sit.png"

enum DIRECTION { LEFT, DOWN, NONE }

var movement_direction: DIRECTION = DIRECTION.LEFT
var flight_speed: float = 500
var entity_textures: Dictionary[String, Texture2D] = {}
var current_entity: Variant
var current_entity_path: String
var victory_texture: Texture2D = preload("res://assets/textures/astronaut_tetris/astro-sit-inchair.png")
var entity_scene: PackedScene = preload("res://entities/tetris_mover.tscn")
var pool_texture_data = {
	ASTRONAUT_TEXTURE_PATH: null, # this one should never be invokved
	"res://assets/textures/astronaut_tetris/monke.png": {
		'position': Vector2(823, 635),
		'scale': 0.309
	},
	"res://assets/textures/dog_halftone.png": {
		'position': Vector2(823, 542),
		'scale': 0.359
	}
}
var outstanding_entity_paths = pool_texture_data.keys()

func _ready() -> void:
	preload_resources()
	super()

func preload_resources() -> void:
	for path in outstanding_entity_paths:
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
		if is_correct():
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
	if is_correct():
		$Chair/ChairSprite.texture = victory_texture
		win()
	else:
		var transforms = pool_texture_data[current_entity_path]
		var new_sprite = Sprite2D.new()
		new_sprite.texture = entity_textures[current_entity_path]
		new_sprite.position = transforms['position']
		new_sprite.scale = Vector2(transforms['scale'], transforms['scale'])
		new_sprite.z_index = 2
		new_sprite.show()
		add_child(new_sprite)
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
	current_entity_path = texture_result[0]
	add_child(entity)

func is_correct() -> bool:
	return current_entity_path == ASTRONAUT_TEXTURE_PATH

func random_entity_texture() -> Array:
	var size = outstanding_entity_paths.size()
	var random_key = outstanding_entity_paths[randi() % size]
	var texture = entity_textures[random_key]
	outstanding_entity_paths.erase(random_key)
	return [random_key, texture]
	
func entity_out_of_bounds() -> bool:
	if current_entity == null:
		return false
		
	return current_entity.position.x >= get_viewport_rect().size.x || current_entity.position.y >= get_viewport_rect().size.y
