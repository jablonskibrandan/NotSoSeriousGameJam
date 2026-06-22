extends Camera3D
class_name OrbitCam

@export var anchor:Node3D

@export var initial_angle_deg:Vector2
@export var initial_distance:float
@export_group("Properties")
@export var min_zoom_distance:float=5.0
@export var max_zoom_distance:float=20.0
@export var rotate_sensitivity:float=0.01
@export var zoom_sensitivity:float=1


var angle:Vector2
var distance:float=2.0
var dragging:bool=false


var _initial_mouse_position:Vector2
var _inital_angle:Vector2

func _ready() -> void:
	angle.x=deg_to_rad(initial_angle_deg.x)
	angle.y=deg_to_rad(initial_angle_deg.y)
	distance=initial_distance
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pan_camera"):
		_initial_mouse_position=get_viewport().get_mouse_position()
		_inital_angle=angle
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
	
func move_camera()->void:
	var angle_vector:=Vector3.FORWARD
	angle_vector*=distance
	angle_vector=angle_vector.rotated(Vector3.LEFT,angle.y).rotated(Vector3.UP,angle.x)
	var anchor_pos:=anchor.global_position
	global_position=anchor_pos+angle_vector
	look_at(anchor_pos)

