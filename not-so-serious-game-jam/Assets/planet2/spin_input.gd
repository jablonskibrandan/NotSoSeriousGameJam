extends ReferenceRect
class_name SpinInput

@export var drag_sensitivity:float=1.0
@export var input_mode:INPUT_MODE
@export var virtual_radius:float=1.0
@export var show_virtual_radius:bool=false
@export_category("Momentum Mode")
@export var drag_force:float=0.5
@export var momentum_falloff:float=0.9
@export_category("References")
@export var game_data:GameData
@export var orbit_cam:OrbitCam

enum INPUT_MODE {
	ScreenDragMode,
	PlanetDragMode,
}

var _dragging_mouse:bool=false
var _last_mouse_position_x:float=0.0
var _enabled_momentum_mode:bool=false
var _momentum:float=0.0

func _ready() -> void:
	assert(game_data,"Please assign game_data in SpinInput")

func _gui_input(event: InputEvent) -> void:
	var mouse_pos=get_global_mouse_position()
	var offset=mouse_pos-get_viewport().get_visible_rect().size/2
	var mouse_dist_to_center:=offset.length_squared()
			
	if event.is_action_pressed("drag_object"):
		if input_mode==INPUT_MODE.PlanetDragMode:
			if mouse_dist_to_center<=get_virtual_radius()**2:
				_dragging_mouse=true
		else:
			_dragging_mouse=true
	
	orbit_cam.dual_mode_hovering=mouse_dist_to_center>get_virtual_radius()**2
	
func _process(delta: float) -> void:
	if Input.is_action_just_released("drag_object"):
		_dragging_mouse=false
	
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
	
	queue_redraw()
	
func _draw():
	if show_virtual_radius:
		match input_mode:
			INPUT_MODE.ScreenDragMode:
				var rect:=get_rect()
				rect.position-=position
				draw_rect(rect,Color(0.89, 0.647, 0.0, 0.306),true)
				draw_rect(rect,Color(0.891, 0.646, 0.0, 1.0),false,5.0)
			INPUT_MODE.PlanetDragMode:
				draw_circle(size/2.0,get_virtual_radius(),Color(0.89, 0.647, 0.0, 0.306),true)
				draw_circle(size/2.0,get_virtual_radius(),Color(0.891, 0.646, 0.0, 1.0),false,5.0)
	
func get_virtual_radius()->float:
	var camera_vector:=orbit_cam.global_position-orbit_cam.anchor.global_position
	var distance:float=camera_vector.length()
	var angle:=atan(virtual_radius/(distance))
	var ratio:=rad_to_deg(angle)/orbit_cam.fov
	var height:=1080.0*ratio
	return height
