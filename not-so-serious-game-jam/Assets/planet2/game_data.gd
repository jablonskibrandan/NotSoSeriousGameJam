extends Node
class_name GameData

var total_rotation:float=0.0 #In radians
var total_spins:int=0

var _spin_remainder:float=0.0
var _base_spin:float=0.0


func increase_rotation(amount:float)->void:
	amount=max(amount,0)
	total_rotation+=amount
	
	_spin_remainder+=amount
	if _spin_remainder>=2*PI:
		var spins_to_add:int=floori(_spin_remainder/(2*PI))
		var new_remainder:float=_spin_remainder-spins_to_add*2*PI
		_spin_remainder=new_remainder
		total_spins+=spins_to_add
	
	print(total_spins)

func increase_base_spin(amount:float)->void:
	_base_spin+=amount
	_base_spin=max(0,_base_spin)
	
func _process(delta: float) -> void:
	increase_rotation(delta*_base_spin)
