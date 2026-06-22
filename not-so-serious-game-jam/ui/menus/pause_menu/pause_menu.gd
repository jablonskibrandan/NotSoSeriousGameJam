extends Control

signal resume_requested()

signal options_requested()
signal guide_requested()
signal main_menu_requested()
signal restart_requested()
signal exit_requested()

const _DIM := 0.38
const _TWEEN_DUR := 0.14

@onready var _sfx_hover: AudioStreamPlayer = $SFX/Hover
@onready var _sfx_click: AudioStreamPlayer = $SFX/Click
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
	_sfx_click.play()
	resume_requested.emit()


func _on_restart_pressed() -> void:
	_sfx_click.play()
	restart_requested.emit()





func _on_options_pressed() -> void:
	_sfx_click.play()
	options_requested.emit()

func _on_guide_pressed() -> void:
	_sfx_click.play()
	guide_requested.emit()


func _on_main_menu_pressed() -> void:
	_sfx_click.play()
	main_menu_requested.emit()


func _on_exit_pressed() -> void:
	_sfx_click.play()
	exit_requested.emit()


func _on_active_state_changed(btn: Button) -> void:
	var is_active := UIConstants.is_button_active(btn)
	btn.pivot_offset = Vector2(0, btn.size.y / 2)
	
	var tween: Tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	if is_active:
		_sfx_hover.play()
		tween.tween_property(btn, "modulate", Color(1.2, 1.2, 1.2, 1.0), _TWEEN_DUR)
		tween.tween_property(btn, "scale", Vector2(1.05, 1.05), _TWEEN_DUR)
	else:
		tween.tween_property(btn, "modulate", Color(1, 1, 1, _DIM), _TWEEN_DUR)
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), _TWEEN_DUR)
