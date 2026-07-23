class_name NumberWheel
extends Node3D

signal stepped(digit: int) 
signal became_idle(digit: int)

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var tick: AudioStreamPlayer3D = $tick

@export var play_ticks := true
@export_range(0.0, 0.5, 0.01) var tick_pitch_jitter := 0.05
## Ticks closer together than this are dropped, so fast spins don't machine-gun.
@export var min_tick_interval := 0.04

@export_group("Speed")
## Each queued step beyond the first speeds the wheel up by this much.
@export var speed_ramp := 0.35
@export var max_speed := 6.0

var digit := 0

var _pending := 0          # >0 counting down, <0 counting up
var _suppress_tick := false
var _last_tick_msec := 0

func _ready() -> void:
	anim.animation_finished.connect(_on_animation_finished)

## Queue N downward steps. Safe to call while the wheel is already moving.
func step_down(count := 1) -> void:
	if count <= 0:
		return
	_pending += count
	if not anim.is_playing():
		_advance()

## Queue N upward steps.
func step_up(count := 1) -> void:
	if count <= 0:
		return
	_pending -= count
	if not anim.is_playing():
		_advance()

## Jump straight to a digit with no animation and no tick.
func snap_to_digit(d: int) -> void:
	_pending = 0
	digit = wrapi(d, 0, 10)
	_suppress_tick = true
	anim.play(str(digit))
	anim.seek(anim.current_animation_length, true)
	anim.pause()
	_suppress_tick = false

func reset() -> void:
	_pending = 0
	digit = 0
	_suppress_tick = true
	anim.play("reset")
	anim.seek(anim.current_animation_length, true)
	anim.pause()
	_suppress_tick = false

func is_moving() -> bool:
	return _pending != 0 or anim.is_playing()

func _advance() -> void:
	if _pending == 0:
		anim.speed_scale = 1.0
		became_idle.emit(digit)
		return

	anim.speed_scale = clampf(1.0 + (absi(_pending) - 1) * speed_ramp, 1.0, max_speed)

	if _pending > 0:
		_pending -= 1
		digit = wrapi(digit - 1, 0, 10)
		anim.play(str(digit))
	else:
		_pending += 1
		# Animation for the *current* digit, reversed, carries us to digit + 1.
		var playing := digit
		digit = wrapi(digit + 1, 0, 10)
		anim.play_backwards(str(playing))

func _on_animation_finished(anim_name: StringName) -> void:
	if _suppress_tick or anim_name == &"reset" or anim_name == &"spin":
		return
	_play_tick()
	stepped.emit(digit)
	_advance()

func _play_tick() -> void:
	if not play_ticks or tick == null:
		return
	var now := Time.get_ticks_msec()
	if now - _last_tick_msec < int(min_tick_interval * 1000.0):
		return
	_last_tick_msec = now
	tick.pitch_scale = 1.0 + randf_range(-tick_pitch_jitter, tick_pitch_jitter)
	tick.play()
