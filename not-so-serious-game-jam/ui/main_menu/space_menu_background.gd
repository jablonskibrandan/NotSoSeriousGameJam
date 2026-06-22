extends Node3D

@onready var planet: RigidBody3D = $SpinnableObject

func _process(delta: float) -> void:
	if is_instance_valid(planet):
		planet.rotate_y(0.05 * delta)
