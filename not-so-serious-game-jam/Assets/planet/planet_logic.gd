extends Node

@export var game:Game
@export var spinnable:SpinnableObject

@export var SunAnchor:Node3D
@export var orbital_radius:float=10.0
const DAY_YEAR_RATIO:float=1/365.0


var last_rotation:float=0.0

func _process(delta: float) -> void:
	var planet_rotation:=spinnable.cummulative_angle
	var rotation_delta=planet_rotation-last_rotation
	last_rotation=planet_rotation
	
	game.increase_rotation(rotation_delta)
	
	set_orbital_position(planet_rotation*DAY_YEAR_RATIO)

func set_orbital_position(phase:float)->void:
	var direction_vector:=Vector3.FORWARD.rotated(Vector3.UP,phase)
	var position_vector:=spinnable.global_position+direction_vector*orbital_radius
	SunAnchor.global_position=position_vector # DOn't ask why im moving the sun
	SunAnchor.rotation.y=phase
