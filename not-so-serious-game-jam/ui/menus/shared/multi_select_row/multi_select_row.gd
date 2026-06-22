extends HBoxContainer

signal value_changed(index: int)

@export_group("Data Control")
@export var options: Array[String] = []:
	set(v):
		options = v
		if is_node_ready():
			_rebuild()

@export var current_index: int = 0:
	set(v):
		if options.is_empty():
			current_index = 0
			return
		current_index = clampi(v, 0, options.size() - 1)
		if is_node_ready():
			_update_visuals()

@export_group("Visual Style")
@export var active_alpha: float = 1.0
@export var tween_duration: float = 0.12

@onready var _template_button: Button = %TemplateButton
@onready var _template_separator: Label = %TemplateSeparator

var _tweens: Dictionary = {}


func _ready() -> void:
	_rebuild()


func _rebuild() -> void:
	for child in get_children():
		if child != _template_button and child != _template_separator:
			child.queue_free()
	
	for i in range(options.size()):
		var btn: Button = _template_button.duplicate() as Button
		btn.text = options[i]
		btn.name = "Option_" + str(i)
		btn.visible = true
		btn.focus_mode = Control.FOCUS_ALL
		btn.add_theme_stylebox_override("focus", UIConstants.focus_style)
		btn.pressed.connect(_on_btn_pressed.bind(i))
		btn.mouse_entered.connect(btn.grab_focus)
		btn.focus_entered.connect(_on_active_state_changed.bind(i))
		btn.focus_exited.connect(_on_active_state_changed.bind(i))
		
		btn.set_meta("select_index", i)
		add_child(btn)
		
		if i < options.size() - 1:
			var sep: Label = _template_separator.duplicate() as Label
			sep.visible = true
			sep.modulate.a = UIConstants.DIM_ALPHA
			add_child(sep)
			
	_update_visuals(0.0)


func _get_button_for_index(idx: int) -> Button:
	for child in get_children():
		if child is Button and child.get_meta("select_index", -1) == idx:
			return child as Button
	return null


func _update_visuals(dur: float = tween_duration) -> void:
	for i in range(options.size()):
		var btn: Button = _get_button_for_index(i)
		if not btn: continue
		
		var is_selected: bool = (i == current_index)
		var target_alpha: float = active_alpha if is_selected else UIConstants.DIM_ALPHA
		
		_tween_to(btn, target_alpha, dur)


func _tween_to(btn: Button, alpha: float, dur: float) -> void:
	if _tweens.has(btn):
		_tweens[btn].kill()
	
	if dur <= 0.0:
		btn.modulate.a = alpha
		return
		
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(btn, "modulate:a", alpha, dur)
	_tweens[btn] = tween


func _on_btn_pressed(idx: int) -> void:
	if current_index != idx:
		current_index = idx
		value_changed.emit(idx)


func _on_active_state_changed(idx: int) -> void:
	var btn: Button = _get_button_for_index(idx)
	if not btn: return
	
	if current_index == idx: return
	
	var is_active := UIConstants.is_button_active(btn)
	var target_alpha: float = 0.8 if is_active else UIConstants.DIM_ALPHA
	_tween_to(btn, target_alpha, tween_duration)
