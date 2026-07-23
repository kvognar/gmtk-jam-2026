class_name Counter
extends Node3D

signal value_changed(new_value: int)
signal spin_finished(value: int)

@onready var thousands: NumberWheel = %thousands
@onready var hundreds: NumberWheel = %hundreds
@onready var tens: NumberWheel = %tens
@onready var ones: NumberWheel = %ones

@export_group("Startup")
@export var initial_value := 0
@export var spin_to_on_start := 0
@export var start_spin_delay := 0.4

@export_group("Testing")
# if testing is on, you can press up and down on the arrow keys to increment the count
@export var enable_test_input := true

@export_group("Behaviour")
## When a jump is equally far up or down (e.g. 0 -> 5000), roll downward.
@export var prefer_down_on_tie := true

var _wheels: Array[NumberWheel] = []
var _value := 0
var _was_moving := false

func _ready() -> void:
	_wheels = [ones, tens, hundreds, thousands]
	snap_to(initial_value)
	if spin_to_on_start != initial_value:
		if start_spin_delay > 0.0:
			await get_tree().create_timer(start_spin_delay).timeout
		set_value(spin_to_on_start)

func _process(_delta: float) -> void:
	var moving := is_spinning()
	if _was_moving and not moving:
		spin_finished.emit(_value)
	_was_moving = moving

func _unhandled_input(event: InputEvent) -> void:
	if not enable_test_input:
		return
	if event.is_action_pressed("ui_down"):
		add(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		add(1)
		get_viewport().set_input_as_handled()

var value: int:
	get:
		return _value

func set_value(v: int, animate := true) -> void:
	var m := _modulus()
	var wanted := wrapi(v, 0, m)
	if wanted == _value:
		return
	if not animate:
		snap_to(wanted)
		return

	var down := wrapi(_value - wanted, 0, m)   # steps needed going down
	var up := m - down                         # steps needed going up
	if down < up or (down == up and prefer_down_on_tie):
		_drive(down, true)
	else:
		_drive(up, false)

func add(delta: int, animate := true) -> void:
	if delta == 0:
		return
	if not animate:
		snap_to(_value + delta)
		return
	_drive(absi(delta), delta < 0)

func snap_to(v: int) -> void:
	_value = wrapi(v, 0, _modulus())
	for i in _wheels.size():
		_wheels[i].snap_to_digit(_digit_at(_value, i))
	value_changed.emit(_value)

func is_spinning() -> bool:
	for w in _wheels:
		if w.is_moving():
			return true
	return false

func _modulus() -> int:
	return int(pow(10.0, float(_wheels.size())))

func _digit_at(v: int, place: int) -> int:
	return (v / int(pow(10.0, float(place)))) % 10

## Queues `steps` single-digit moves. Each wheel only turns as many times as its
## own column actually changes, which is the carry: the tens wheel moves once
## per ten steps, the hundreds once per hundred, and so on.
func _drive(steps: int, down: bool) -> void:
	if steps <= 0:
		return
	var from := _value
	var to := from - steps if down else from + steps

	for i in _wheels.size():
		var scale := int(pow(10.0, float(i)))
		var turns := absi(_floor_div(from, scale) - _floor_div(to, scale))
		if turns == 0:
			continue
		if down:
			_wheels[i].step_down(turns)
		else:
			_wheels[i].step_up(turns)

	_value = wrapi(to, 0, _modulus())
	_was_moving = true
	value_changed.emit(_value)

## Integer division that rounds toward negative infinity, so wrapping past zero
## still counts as one turn of the higher wheels.
func _floor_div(a: int, b: int) -> int:
	return floori(float(a) / float(b))
