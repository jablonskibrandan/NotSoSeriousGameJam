extends Control
class_name GameOverMenu

@onready var _restart_btn: Button = %RestartButton
@onready var _menu_btn: Button = %MenuButton


func _ready() -> void:
	for btn: Button in [_restart_btn, _menu_btn]:
		btn.focus_mode = Control.FOCUS_ALL
		btn.focus_entered.connect(_on_focus_entered.bind(btn))
		btn.focus_exited.connect(_on_active_state_changed.bind(btn))
		btn.mouse_entered.connect(btn.grab_focus)
		btn.pressed.connect(func() -> void: MusicManager.play_ui_click())
		_on_active_state_changed(btn)
	
	$AnimationPlayer.play("fade_in")
	
	# Give a frame for the UI to settle before grabbing focus
	await get_tree().process_frame
	_restart_btn.grab_focus()


func _on_focus_entered(btn: Button) -> void:
	MusicManager.play_ui_hover()
	_on_active_state_changed(btn)


func _on_active_state_changed(btn: Button) -> void:
	var is_active := UIConstants.is_button_active(btn)
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	if is_active:
		tween.tween_property(btn, "modulate", UIConstants.HOVER_MODULATE, UIConstants.TWEEN_DURATION)
	else:
		tween.tween_property(btn, "modulate", Color(1, 1, 1, UIConstants.DIM_ALPHA), UIConstants.TWEEN_DURATION)
