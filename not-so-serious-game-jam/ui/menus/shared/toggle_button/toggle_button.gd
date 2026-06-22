extends Button

signal toggled_value(enabled: bool)

@export var enabled_text: String = "ON"
@export var disabled_text: String = "OFF"

var is_on: bool = false : set = _set_on


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	add_theme_stylebox_override("focus", UIConstants.focus_style)
	pressed.connect(_on_pressed)
	mouse_entered.connect(grab_focus)
	focus_entered.connect(_on_active_state_changed)
	focus_exited.connect(_on_active_state_changed)
	_update_display()
	_on_active_state_changed()


func _set_on(val: bool) -> void:
	is_on = val
	_update_display()


func _update_display() -> void:
	if not is_node_ready():
		return
	text = enabled_text if is_on else disabled_text


func _on_pressed() -> void:
	is_on = !is_on
	toggled_value.emit(is_on)


func _on_active_state_changed() -> void:
	var is_active := UIConstants.is_button_active(self)
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	var target_alpha: float = UIConstants.BRIGHT_ALPHA if is_active else UIConstants.DIM_ALPHA
	tween.tween_property(self, "modulate:a", target_alpha, UIConstants.TWEEN_DURATION)
