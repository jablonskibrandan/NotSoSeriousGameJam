extends Control

signal close_requested()

@onready var _back_btn: Button = %BackButton
@onready var _sfx_hover: AudioStreamPlayer = $SFX/Hover
@onready var _sfx_click: AudioStreamPlayer = $SFX/Click


func _ready() -> void:
	for btn: Button in [_back_btn]:
		btn.focus_mode = Control.FOCUS_ALL
		btn.add_theme_stylebox_override("focus", UIConstants.focus_style)
		btn.mouse_entered.connect(btn.grab_focus)
		btn.focus_entered.connect(_on_active_state_changed.bind(btn))
		btn.focus_exited.connect(_on_active_state_changed.bind(btn))


func _on_back_pressed() -> void:
	_sfx_click.play()
	close_requested.emit()


func _on_active_state_changed(btn: Button) -> void:
	var is_active := UIConstants.is_button_active(btn)
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	var target_alpha: float = UIConstants.BRIGHT_ALPHA if is_active else UIConstants.DIM_ALPHA
	if is_active:
		_sfx_hover.play()
	
	tween.tween_property(btn, "modulate:a", target_alpha, UIConstants.TWEEN_DURATION)
