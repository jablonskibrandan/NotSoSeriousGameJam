@icon("res://Assets/icons/icon_assets/addons/at-icons/node/orbit.svg")
extends Node
class_name GameData

var total_rotation: float = 0.0
var total_spins: int = 0
var _spin_remainder: float = 0.0

@export var _base_spin: float = 2.0 * PI / 60.0
@export var currency_reward_per_rotation: int = 250

func increase_rotation(amount: float) -> void:
	amount = max(amount, 0.0)
	total_rotation += amount
	_spin_remainder += amount
	_check_for_spin()
	
func _check_for_spin()->void:
	if _spin_remainder >= 2.0 * PI:
		var spins_to_add := floori(_spin_remainder / (2.0 * PI))
		var new_remainder := _spin_remainder - spins_to_add * 2.0 * PI
		_spin_remainder = new_remainder
		total_spins += spins_to_add
		
		GameManagerObject.add_to_current_currency(spins_to_add * currency_reward_per_rotation)
		GameManagerObject.on_planet_rotation_completed(spins_to_add)
		GameManagerObject.shorten_year_length(spins_to_add)

func increase_base_spin(amount: float) -> void:
	_base_spin += amount
	_base_spin = max(0.0, _base_spin)
	
func _process(delta: float) -> void:
	increase_rotation(delta * _base_spin)
