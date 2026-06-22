extends Node

const DIM_ALPHA: float = 0.38
const BRIGHT_ALPHA: float = 1.0
const TWEEN_DURATION: float = 0.14
const HOVER_SCALE: Vector2 = Vector2(1.05, 1.05)
const HOVER_MODULATE: Color = Color(1.3, 1.3, 1.3, 1.0)
const DIALOG_HOVER_MODULATE: Color = Color(1.2, 1.2, 1.2, 1.0)

var focus_style: StyleBox = preload("res://ui/shared/focus_style.tres")

func is_button_active(btn: Button) -> bool:
	var viewport = btn.get_viewport()
	if not viewport: return btn.is_hovered()
	
	var focus_owner = viewport.gui_get_focus_owner()
	if focus_owner:
		return btn == focus_owner
	return btn.is_hovered()
