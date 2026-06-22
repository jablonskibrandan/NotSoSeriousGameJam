extends ReferenceRect
class_name SpinInput

@export var game_data:GameData
@export var drag_sensitivity:float=1.0
@export_category("Momentum Mode")
@export var drag_force:float=0.5
@export var momentum_falloff:float=0.9

var _dragging_mouse:bool=false
var _last_mouse_position_x:float=0.0
var _enabled_momentum_mode:bool=false
var _momentum:float=0.0

func _ready() -> void:
	assert(game_data,"Please assign game_data in SpinInput")

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("drag_object"):
		_dragging_mouse=true
		
	if event.is_action_released("drag_object"):
		_dragging_mouse=false
		
func _process(delta: float) -> void:
	var _mouse_x:float=get_global_mouse_position().x
	var _mouse_delta_x:float=max(0,_mouse_x-_last_mouse_position_x)
	if not _dragging_mouse: _mouse_delta_x=0.0
	_last_mouse_position_x=_mouse_x
	
	#So that larger screens don't have an advantage:
	var _screen_width:float=DisplayServer.window_get_size().x
	var _normalized_delta_x:float=_mouse_delta_x/_screen_width
	
	if game_data:
		if _enabled_momentum_mode:
			_momentum+=_normalized_delta_x*drag_force
			var _spin_amount:=_momentum
			_momentum-=_momentum*delta*momentum_falloff
			game_data.increase_rotation(_spin_amount)
		else:
			var _spin_amount:=_normalized_delta_x*drag_sensitivity
			game_data.increase_rotation(_spin_amount)
		
		
	
