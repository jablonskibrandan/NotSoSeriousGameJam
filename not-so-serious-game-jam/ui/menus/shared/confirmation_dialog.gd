extends Control

signal confirmed()
signal cancelled()

const _COLOR_CONFIRM := Color(1, 0.4, 0.4)
const _DIM_CANCEL := 0.38
const _DIM_CONFIRM := 0.6
const _TWEEN_DUR := 0.14

@onready var _message_label: Label = %MessageLabel
@onready var _confirm_btn: Button = %ConfirmButton
@onready var _cancel_btn: Button = %CancelButton


func _ready() -> void:
	for btn: Button in [_confirm_btn, _cancel_btn]:
		btn.focus_mode = Control.FOCUS_ALL
		btn.add_theme_stylebox_override("focus", UIConstants.focus_style)
		btn.mouse_entered.connect(btn.grab_focus)
		btn.focus_entered.connect(_on_active_state_changed.bind(btn))
		btn.focus_exited.connect(_on_active_state_changed.bind(btn))


func setup(message: String, confirm_text: String = "PROCEED", cancel_text: String = "CANCEL") -> void:
	_message_label.text = message
	_confirm_btn.text = confirm_text
	_cancel_btn.text = cancel_text


func _on_confirm_pressed() -> void:
	MusicManager.play_ui_click()
	confirmed.emit()


func _on_cancel_pressed() -> void:
	MusicManager.play_ui_click()
	cancelled.emit()


func _on_active_state_changed(btn: Button) -> void:
	var is_active := UIConstants.is_button_active(btn)
	btn.pivot_offset = btn.size / 2
	
	var tween := create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	if is_active:
		MusicManager.play_ui_hover()
		var mod_color = Color(1.3, 0.6, 0.6, 1.0) if btn == _confirm_btn else UIConstants.DIALOG_HOVER_MODULATE
		tween.tween_property(btn, "modulate", mod_color, UIConstants.TWEEN_DURATION)
		tween.tween_property(btn, "scale", Vector2(1.1, 1.1), UIConstants.TWEEN_DURATION)
	else:
		var exit_color: Color
		if btn == _confirm_btn:
			exit_color = Color(_COLOR_CONFIRM.r, _COLOR_CONFIRM.g, _COLOR_CONFIRM.b, UIConstants.DIM_ALPHA)
		else:
			exit_color = Color(1, 1, 1, UIConstants.DIM_ALPHA)
		
		tween.tween_property(btn, "modulate", exit_color, UIConstants.TWEEN_DURATION)
		tween.tween_property(btn, "scale", Vector2.ONE, UIConstants.TWEEN_DURATION)
