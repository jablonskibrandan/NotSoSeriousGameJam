extends ReferenceRect
class_name SpinInput

@export var game_data:GameData
@export var drag_sensitivity:float=1.0

var _dragging_mouse:bool=false
var _last_mouse_position_x:float=0.0

func _ready() -> void:
	assert(game_data,"Please assign game_data in SpinInput")

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("drag_object"):
		_dragging_mouse=true
		
	var _mouse_x:float=get_global_mouse_position().x
	var _mouse_delta_x:float=_mouse_x-_last_mouse_position_x
	_last_mouse_position_x=_mouse_x
	
	#So that larger screens don't have an advantage:
	var _screen_width:float=DisplayServer.window_get_size().x
	var _normalized_delta_x:float=_mouse_delta_x/_screen_width
	
	if game_data and _dragging_mouse:
		game_data.increase_rotation(_normalized_delta_x*drag_sensitivity)
		
	if event.is_action_released("drag_object"):
		_dragging_mouse=false
