extends Node

@onready var planet_orbit: PlanetOrbit = $"../Planet" as PlanetOrbit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func _on_speed_up_pressed(increase_value: int, spend_currency: int) -> void:
	planet_orbit.increase_base_spin_per_second(increase_value)
	GameManagerObject.try_spend_currency(spend_currency)
