extends Microgame
class_name AstronautTetris

@export var entities: Array[TetrisMover] = []

enum DIRECTION { LEFT, DOWN, NONE }

var movement_direction: DIRECTION = DIRECTION.LEFT
var flight_speed: float = 1000
var entity_textures: Dictionary[String, Texture2D] = {}
var current_entity: TetrisMover
var victory_texture: Texture2D = preload("res://assets/textures/astronaut_tetris/astro-sit-inchair.png")
var missing_sound: AudioStream = preload("res://assets/audio/voice/majortom_1.ogg")

func _ready() -> void:
	for entity in entities:
		entity.position = $EntitySpawner.position
		entity.hide()
	super()
	
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
		current_entity.call_deferred('free')
		if is_correct():
			play_missing_sound()
			lose()
			return
		else:
			spawn_entity()
	

func start_astronaut_movement() -> void:
	$Astronaut.show()
	movement_direction = DIRECTION.LEFT

func play_missing_sound() -> void:
	var player = AudioStreamPlayer.new()
	player.stream = missing_sound
	add_child(player)
	player.play(2.07)

func play_chair_entered_sound() -> void:
	var entry_sound_player = AudioStreamPlayer.new()
	entry_sound_player.stream = current_entity.chair_enter_sound
	add_child(entry_sound_player)
	entry_sound_player.play()
	

func _on_chair_area_entered(area: Area2D) -> void:
	if !playing:
		return
	
	$Timer.stop()
	movement_direction = DIRECTION.NONE
	current_entity.hide()
	play_chair_entered_sound()
	if is_correct():
		$Chair/ChairSprite.texture = victory_texture
		win()
	else:

		var new_sprite = Sprite2D.new()
		new_sprite.texture = current_entity.texture
		new_sprite.position = current_entity.chair_position
		new_sprite.scale = current_entity.victory_scale
		new_sprite.z_index = 2
		new_sprite.show()
		add_child(new_sprite)
		lose()
	
func begin() -> void:
	super()
	
func _on_prompt_timer_timeout() -> void:
	$PromptTimer.stop()
	spawn_entity()

func spawn_entity() -> void:
	if entities.size() == 0:
		lose()
		return
	
	var entity = random_entity()
	entity.position = $EntitySpawner.position
	current_entity = entity
	entity.show()
	movement_direction = DIRECTION.LEFT

func is_correct() -> bool:
	return current_entity.is_winning

func random_entity() -> TetrisMover:
	var size = entities.size()
	var random_value = entities[randi() % size]
	entities.erase(random_value)
	return random_value
	
func entity_out_of_bounds() -> bool:
	if current_entity == null:
		return false
		
	return current_entity.position.x >= get_viewport_rect().size.x || current_entity.position.y >= get_viewport_rect().size.y
