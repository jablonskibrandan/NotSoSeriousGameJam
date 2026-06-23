extends Camera3D
class_name OrbitCam

@export var anchor:Node3D

@export var initial_angle_deg:Vector2
@export var initial_distance:float
@export_group("Properties")
@export var min_zoom_distance: float = 5.0
@export var max_zoom_distance: float = 20.0
@export var rotate_sensitivity: float = 0.01
@export var zoom_sensitivity: float = 1
@export var horizontal_screen_offset_factor: float = 0.25

enum MODE {
	StandardOrbit,
	DualLeftClick,
}
@export var camera_mode:MODE

var angle:Vector2
var distance:float=2.0
var dragging:bool=false
var dual_mode_hovering:bool=false

var _initial_mouse_position:Vector2
var _inital_angle:Vector2

# Juice & Shake Properties
@export var shake_decay: float = 5.0
var shake_intensity: float = 0.0

func _ready() -> void:
	angle.x=deg_to_rad(initial_angle_deg.x)
	angle.y=deg_to_rad(initial_angle_deg.y)
	distance=initial_distance
	
func _process(delta: float) -> void:
	if shake_intensity > 0.0:
		shake_intensity = maxf(0.0, shake_intensity - shake_decay * delta)

	if Input.is_action_just_pressed("pan_camera"):
		_initial_mouse_position=get_viewport().get_mouse_position()
		_inital_angle=angle
		dragging=true
	if Input.is_action_just_pressed("drag_object"):
		_initial_mouse_position=get_viewport().get_mouse_position()
		_inital_angle=angle
		if camera_mode==MODE.DualLeftClick:
			if dual_mode_hovering:
				dragging=true
		
	if dragging:
		var _mouse_delta:Vector2=get_viewport().get_mouse_position()-_initial_mouse_position
		angle=_inital_angle-_mouse_delta*rotate_sensitivity
		angle.y=clamp(angle.y,-PI/2+0.01,PI/2-0.01)
		
	var _zoom_delta:float=int(Input.is_action_just_pressed("zoom_in"))-int(Input.is_action_just_pressed("zoom_out"))
	distance+=_zoom_delta*zoom_sensitivity
	distance=clamp(distance,min_zoom_distance,max_zoom_distance)
	
	move_camera()
		
	if Input.is_action_just_released("pan_camera"):
		dragging=false
	if Input.is_action_just_released("drag_object") and camera_mode==MODE.DualLeftClick:
		dragging=false
		
func add_shake(intensity: float) -> void:
	shake_intensity = clamp(shake_intensity + intensity, 0.0, 1.5)

func move_camera()->void:
	var angle_vector:=Vector3.FORWARD
	angle_vector*=distance
	angle_vector=angle_vector.rotated(Vector3.LEFT,angle.y).rotated(Vector3.UP,angle.x)
	var anchor_pos:=anchor.global_position
	
	var offset := Vector3.ZERO
	if shake_intensity > 0.0:
		offset = Vector3(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		
	global_position = anchor_pos + angle_vector + offset
	look_at(anchor_pos)
	
	# Framed horizontally to offset for the HUD shop UI on the right
	h_offset = distance * horizontal_screen_offset_factor
