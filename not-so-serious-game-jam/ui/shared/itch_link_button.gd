extends Control

signal hovered
signal clicked

@export var url: String = ""
@export var action_name: StringName = &"interact"
@export var icon_texture: Texture2D

@onready var _icon: TextureRect = $Icon
@onready var _glow: TextureRect = $Glow
@onready var _input_icon: TextureRect = %InputIcon

var _base_scale: Vector2

func _ready() -> void:
	if icon_texture:
		_icon.texture = icon_texture
		_glow.texture = icon_texture
	
	_base_scale = scale
	_update_prompt()
	

	
	# Simple Initial State
	_glow.modulate.a = 0.0
	_input_icon.modulate.a = 1.0
	_input_icon.scale = Vector2.ONE

	var btn := $Button as Button
	if btn:
		btn.focus_entered.connect(_on_button_mouse_entered)
		btn.focus_exited.connect(_on_button_mouse_exited)
		btn.add_theme_stylebox_override("focus", UIConstants.focus_style)


func _input(event: InputEvent) -> void:
	if is_visible_in_tree() and event.is_action_pressed(action_name):
		_on_pressed()


func _on_button_mouse_entered() -> void:
	var tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", _base_scale * 1.05, 0.1)
	tween.tween_property(_glow, "modulate:a", 0.5, 0.1)
	hovered.emit()


func _on_button_mouse_exited() -> void:
	var tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", _base_scale, 0.1)
	tween.tween_property(_glow, "modulate:a", 0.0, 0.1)


func _on_pressed() -> void:
	clicked.emit()
	
	# Simple click scale bounce
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", _base_scale * 0.95, 0.05)
	tween.tween_property(self, "scale", _base_scale * 1.05, 0.05)
	
	if not url.is_empty():
		OS.shell_open(url)


func _update_prompt() -> void:
	if _input_icon:
		var ev := SettingsManager.get_kbm_event_for(action_name)
		_input_icon.texture = SettingsManager.get_icon_for_event(ev)
