extends Node3D
class_name PlanetOrbit

signal rotation_completed(total_rotations: int)
signal unlock_rotation_reached(total_rotations: int)

@export var orbit_center: Node3D

@export_group("Planet Spin")
@export var base_spin_degrees_per_second: float = 90.0
@export var drag_spin_boost: float = 0.0
@export var max_drag_spin_boost: float = 2000.0
@export var drag_strength: float = 12.0
@export var drag_decay: float = 300.0

@export_group("Orbit")
@export var orbit_axis: Vector3 = Vector3.UP

@export_group("Resource/Rewards")
@export var resources_per_day: int

var day_progress_degrees: float = 0.0
var is_dragging: bool = false


# We have to do this in order to figure out how many degrees of rotation per day we will need
@onready var orbit_degrees_per_day: float = 360.0 / float(GameManagerObject.DAYS_IN_YEAR)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed

	if event is InputEventMouseMotion and is_dragging:
		# Use the size of the drag, not just left/right direction.
		# This means dragging faster makes the planet spin faster.
		var drag_amount: float = event.relative.length()

		drag_spin_boost += drag_amount * drag_strength
		drag_spin_boost = clamp(drag_spin_boost, 0.0, max_drag_spin_boost)


# I chose not to use physics because we could get some weird movements. I think it's better for it to move in a predictable way.
func _process(delta: float) -> void:
	var current_spin_speed: float = base_spin_degrees_per_second + drag_spin_boost
	var spin_degrees_this_frame: float = current_spin_speed * delta

	spin_planet(spin_degrees_this_frame)
	update_day_progress(spin_degrees_this_frame)
	decay_drag_boost(delta)


func spin_planet(spin_degrees: float) -> void:
	# This is the visual planet spin.
	rotate_y(deg_to_rad(spin_degrees))


func update_day_progress(spin_degrees: float) -> void:
	day_progress_degrees += spin_degrees

	while day_progress_degrees >= 360.0:
		day_progress_degrees -= 360.0
		complete_rotation()


func complete_rotation() -> void:
	shorten_one_day()
	GameManagerObject.add_to_current_currency(resources_per_day)

	rotation_completed.emit(1)


func shorten_one_day() -> void:
	if orbit_center != null:
		move_along_orbit(orbit_degrees_per_day)

	GameManagerObject.shorten_year_length(1)


func move_along_orbit(degrees: float) -> void:
	var center: Vector3 = orbit_center.global_position
	var offset: Vector3 = global_position - center

	#This rotates it about the axis of the orbit, given the offset.
	offset = offset.rotated(orbit_axis.normalized(), deg_to_rad(degrees))

	global_position = center + offset


# Decays the drag boost over time so the player has something to do besides watching it spin!
func decay_drag_boost(delta: float) -> void:
	drag_spin_boost = move_toward(
		drag_spin_boost,
		0.0,
		drag_decay * delta
	)


# TODO: Currently buttons just add to the base spin and that's that. But maybe we want to do something different here?
# This applies the totality of all upgrades to the base spin
func increase_base_spin_per_second(upgrade_boost: float) -> void:
	base_spin_degrees_per_second += upgrade_boost
	print(base_spin_degrees_per_second)
