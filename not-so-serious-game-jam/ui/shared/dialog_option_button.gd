extends Button

func _ready() -> void:
	modulate = Color(1, 1, 1, 0.7)
	focus_mode = Control.FOCUS_ALL
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)


func _on_mouse_entered() -> void:
	grab_focus()


func _on_mouse_exited() -> void:
	pass


func _on_focus_entered() -> void:
	MusicManager.play_ui_hover()
	_animate_active(true)


func _on_focus_exited() -> void:
	_animate_active(false)


func _animate_active(active: bool) -> void:
	if active:
		modulate = Color(1, 1, 1, 1)
	else:
		modulate = Color(1, 1, 1, 0.7)
