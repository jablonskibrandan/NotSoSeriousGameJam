extends Control

signal resume_requested()

signal options_requested()
signal guide_requested()
signal main_menu_requested()
signal restart_requested()
signal exit_requested()

const _DIM := 0.38
const _TWEEN_DUR := 0.14

@onready var _resume_btn: Button = %ResumeButton
@onready var _restart_btn: Button = %RestartButton

@onready var _options_btn: Button = %OptionsButton
@onready var _guide_btn: Button = %GuideButton
@onready var _main_menu_btn: Button = %MainMenuButton
@onready var _exit_btn: Button = %ExitButton


func _ready() -> void:
	for btn: Button in [_resume_btn, _restart_btn, _options_btn, _guide_btn, _main_menu_btn, _exit_btn]:
		btn.focus_mode = Control.FOCUS_ALL
		btn.mouse_entered.connect(btn.grab_focus)
		btn.focus_entered.connect(_on_active_state_changed.bind(btn))
		btn.focus_exited.connect(_on_active_state_changed.bind(btn))


func _on_resume_pressed() -> void:
	MusicManager.play_ui_click()
	resume_requested.emit()


func _on_restart_pressed() -> void:
	MusicManager.play_ui_click()
	restart_requested.emit()


func _on_options_pressed() -> void:
	MusicManager.play_ui_click()
	options_requested.emit()

func _on_guide_pressed() -> void:
	MusicManager.play_ui_click()
	guide_requested.emit()


func _on_main_menu_pressed() -> void:
	MusicManager.play_ui_click()
	main_menu_requested.emit()


func _on_exit_pressed() -> void:
	MusicManager.play_ui_click()
	exit_requested.emit()


func _on_active_state_changed(btn: Button) -> void:
	var is_active := UIConstants.is_button_active(btn)
	btn.pivot_offset = Vector2(0, btn.size.y / 2)
	
	var tween: Tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	if is_active:
		MusicManager.play_ui_hover()
		tween.tween_property(btn, "modulate", Color(1.2, 1.2, 1.2, 1.0), _TWEEN_DUR)
		tween.tween_property(btn, "scale", Vector2(1.05, 1.05), _TWEEN_DUR)
	else:
		tween.tween_property(btn, "modulate", Color(1, 1, 1, _DIM), _TWEEN_DUR)
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), _TWEEN_DUR)
