extends Node2D

@onready var slideshow: CanvasLayer = $slideshow
@onready var slide1: TextureRect = %slide1
@onready var slide2: TextureRect = %slide2
@onready var slide1_audio: AudioStreamPlayer2D = $slideshow/slide1/AudioStreamPlayer2D
@onready var slide2_audio: AudioStreamPlayer2D = $slideshow/slide2/AudioStreamPlayer2D
@onready var typing: AudioStreamPlayer2D = %typing

@export var font: Font = preload("res://assets/intro/Mom差___.ttf")

@export_group("Text Style")
@export var font_size := 48
@export var text_color := Color(0.0, 0.0, 0.0, 1.0)
@export var margin := 48.0

@export_group("Typing")
@export var char_delay := 0.055
@export var line_pause := 0.5

@export_group("Timing")
@export var audio_fade_in := 1.2
@export var slide_fade_in := 1.0
## Slide 1 starts fading in this long after its audio does.
@export var slide_delay := 0.1
@export var hold_after_text := 1.0
@export var text_fade_out := 0.4
@export var crossfade := 1.8
@export var final_fade := 2.0
@export var silent_db := -40.0

var _upper_right: Label
var _lower_left: Label
var _upper_left: Label
var _slide1_db := 0.0
var _slide2_db := 0.0

func _ready():
	_slide1_db = slide1_audio.volume_db
	_slide2_db = slide2_audio.volume_db

	slide1.modulate.a = 0.0
	slide2.modulate.a = 0.0
	slide1_audio.volume_db = silent_db
	slide2_audio.volume_db = silent_db

	_upper_right = _make_label(Control.PRESET_TOP_RIGHT, HORIZONTAL_ALIGNMENT_RIGHT)
	_lower_left = _make_label(Control.PRESET_BOTTOM_LEFT, HORIZONTAL_ALIGNMENT_LEFT)
	_upper_left = _make_label(Control.PRESET_TOP_LEFT, HORIZONTAL_ALIGNMENT_LEFT)

	_run()

func _run():
	_fade_audio(slide1_audio, _slide1_db, audio_fade_in, true)
	await get_tree().create_timer(.2).timeout
	_fade_node(slide1, 1.0, slide_fade_in)
	await _wait(slide_fade_in)

	await _type(_upper_right, "7:44 AM EST MAY 24 1962")
	await _wait(line_pause)

	await _type(_lower_left, "NADA SPACE FACILITY\nCAPE CANAVERAL LAUNCH COMPLEX 14")
	await _wait(hold_after_text)

	# Clear the text, then cross to slide 2.
	_fade_node(_upper_right, 0.0, text_fade_out)
	_fade_node(_lower_left, 0.0, text_fade_out)
	await _wait(text_fade_out)

	_fade_audio(slide1_audio, silent_db, crossfade)
	_fade_audio(slide2_audio, _slide2_db, crossfade, true)
	_fade_node(slide1, 0.0, crossfade)
	_fade_node(slide2, 1.0, crossfade)
	await _wait(crossfade)

	await _type(_upper_left, "MISSION CONTROL CENTER B (THE SMALLER ONE)")
	await _wait(hold_after_text)

	_fade_audio(slide2_audio, silent_db, final_fade)
	_fade_node(_upper_left, 0.0, text_fade_out)
	_fade_node(slide2, 0.0, final_fade)
	await _wait(final_fade)
	_finish()

func _finish():
	get_tree().change_scene_to_file("res://workstation.tscn")

func _make_label(preset: Control.LayoutPreset, align: int) -> Label:
	var label := Label.new()
	label.text = ""
	label.modulate.a = 0.0
	label.horizontal_alignment = align
	label.add_theme_color_override(&"font_color", text_color)
	label.add_theme_font_size_override(&"font_size", font_size)
	if font != null:
		label.add_theme_font_override(&"font", font)
	slideshow.add_child(label)
	label.set_anchors_and_offsets_preset(preset, Control.PRESET_MODE_MINSIZE, int(margin))
	# Vertical growth so multi-line text expands away from its corner.
	if preset == Control.PRESET_BOTTOM_LEFT:
		label.grow_vertical = Control.GROW_DIRECTION_BEGIN
	if align == HORIZONTAL_ALIGNMENT_RIGHT:
		label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	return label

func _type(label: Label, text: String):
	label.text = ""
	label.modulate.a = 1.0
	for i in text.length():
		var c := text[i]
		label.text += c
		if c != " " and c != "\n":
			if typing == null:
				return
			typing.play()
		await _wait(char_delay)

func _fade_node(node: CanvasItem, to_alpha: float, dur: float):
	create_tween().tween_property(node, "modulate:a", to_alpha, dur)

func _fade_audio(player: AudioStreamPlayer2D, to_db: float, dur: float, start := false):
	if start:
		player.volume_db = silent_db
		player.play()
	create_tween().tween_property(player, "volume_db", to_db, dur)

func _wait(seconds: float):
	await get_tree().create_timer(seconds).timeout
