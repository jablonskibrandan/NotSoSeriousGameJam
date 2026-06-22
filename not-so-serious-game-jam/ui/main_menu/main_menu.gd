extends Control

signal start_requested()
signal options_requested()
signal credits_requested()
signal exit_requested()





func _ready() -> void:
	GameManagerObject.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	for btn in get_tree().get_nodes_in_group("menu_buttons"):
		if btn is Button:
			btn.focus_mode = Control.FOCUS_ALL
			btn.mouse_entered.connect(btn.grab_focus)
			btn.focus_entered.connect(_on_active_state_changed.bind(btn))
			btn.focus_exited.connect(_on_active_state_changed.bind(btn))
	
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	if visible:
		# Small delay to ensure focus has been updated if triggered by SceneManager
		await get_tree().process_frame
		_refresh_button_states()


func _refresh_button_states() -> void:
	for btn in get_tree().get_nodes_in_group("menu_buttons"):
		if btn is Button:
			_on_active_state_changed(btn)


func _on_active_state_changed(btn: Button) -> void:
	var is_active := UIConstants.is_button_active(btn)
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	if is_active:
		MusicManager.play_ui_hover()
		tween.tween_property(btn, "modulate", UIConstants.HOVER_MODULATE, UIConstants.TWEEN_DURATION)
	else:
		tween.tween_property(btn, "modulate", Color(1, 1, 1, UIConstants.DIM_ALPHA), UIConstants.TWEEN_DURATION)


func _on_start_pressed() -> void:
	MusicManager.play_ui_click()
	start_requested.emit()


func _on_options_pressed() -> void:
	MusicManager.play_ui_click()
	options_requested.emit()


func _on_credits_pressed() -> void:
	MusicManager.play_ui_click()
	credits_requested.emit()


func _on_exit_pressed() -> void:
	MusicManager.play_ui_click()
	exit_requested.emit()
