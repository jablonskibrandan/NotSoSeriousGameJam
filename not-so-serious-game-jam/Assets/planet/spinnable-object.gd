extends RigidBody3D
class_name SpinnableObject

@export var angular_dampning:=1.0
@export var mouse_brake_amount:float=2.0
@export var drag_torque:float=2.0
var cummulative_angle:float=0.0 #The angle spun by the planet overall
	#Measured in radians. To obtain #no. rotations, divide by (2*PI)
var hovering:bool=false
var dragging:bool=false



var _previous_mouse_position:Vector2

func _ready() -> void:
	mouse_entered.connect(_mouse_enter)
	mouse_exited.connect(_mouse_exit)
	
	axis_lock_angular_x=true
	axis_lock_angular_y=	false
	axis_lock_angular_z=true
	axis_lock_linear_x=true
	axis_lock_linear_y=true
	axis_lock_linear_z=true
	
	angular_damp=angular_dampning
	
func _process(delta: float) -> void:
	var mouse_pos:Vector2=get_viewport().get_mouse_position()
	
	if hovering and Input.is_action_just_pressed("drag_object"):
		_previous_mouse_position=mouse_pos
		dragging=true
		
	if dragging:
		var mouse_delta:float=mouse_pos.x-_previous_mouse_position.x
		_previous_mouse_position=mouse_pos
		rotate_self(mouse_delta,delta)
		
	if Input.is_action_just_released("drag_object"):
		dragging=false
	
func rotate_self(mouse_delta:float,delta:float)->void:
	var axis_vector:=Vector3.UP
	
	var torque:=mouse_delta*drag_torque
	if hovering:
		torque=-angular_velocity.y*mouse_brake_amount

	apply_torque(axis_vector*torque*delta*60.0)
	
func _physics_process(delta: float) -> void:
	cummulative_angle += angular_velocity.y * delta
	#Counts the rotation from the in-game rigidbody
	
func _mouse_enter()->void:
	hovering=true
	
func _mouse_exit()->void:
	hovering=false
