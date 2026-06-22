extends Label

@export var game_data:GameData

func _process(delta: float) -> void:
	text="Days: %d"%[game_data.total_spins]
	text+="\n(total spin: %frad)"%[game_data.total_rotation]
