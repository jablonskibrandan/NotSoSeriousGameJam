extends Node3D
class_name PlanetActor

@export var game_data:GameData
@export var SunAnchor:Node3D
@export var orbital_radius:float=50.0
const YEAR_RATIO:int=365

func _ready() -> void:
	assert(game_data,"Please assign game_data in PlanetActor")
	
func _process(delta: float) -> void:
	var rot:=game_data.total_rotation
	set_orbital_position(rot/YEAR_RATIO)
	set_axis_rotation(rot)

func set_axis_rotation(phase:float)->void:
	self.rotation.y=phase

func set_orbital_position(phase:float)->void:
	var direction_vector:=Vector3.FORWARD.rotated(Vector3.UP,phase)
	var position_vector:=SunAnchor.global_position+direction_vector*orbital_radius
	self.global_position=position_vector
