extends Node
class_name Game

var global_rotation:float=0.0 #In Radians
var global_spins:int=0

@export var PlayerPlanet:SpinnableObject

var _spin_remainder:float=0.0

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	global_rotation=PlayerPlanet.cummulative_angle

func increase_rotation(by:float)->void:
	by=max(by,0)
	global_rotation+=by
	
	_spin_remainder+=by
	if _spin_remainder>=2*PI:
		var spins_to_add:int=floori(_spin_remainder/(2*PI))
		var new_remainder:float=_spin_remainder-spins_to_add*2*PI
		_spin_remainder=new_remainder
		global_spins+=spins_to_add
