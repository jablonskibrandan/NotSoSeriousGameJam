extends Node
class_name UpgradeManager

@export var planet_orbit: PlanetOrbit
@export var upgrade_button_configs: Array[UpgradeButtonConfig] = []

var total_rotations_seen: int = 0
var button_to_config: Dictionary = {}


func _ready() -> void:
	if planet_orbit == null:
		push_error("UpgradeManager needs a PlanetOrbit assigned.")
		return

	planet_orbit.rotation_completed.connect(on_planet_rotation_completed)

	for config in upgrade_button_configs:
		if config == null:
			continue

		var button := get_node_or_null(config.button_path) as Button

		if button == null:
			push_warning("Upgrade config has no valid button path: " + str(config.button_path))
			continue

		button_to_config[button] = config

		button.disabled = true
		button.text = "Locked"


func on_planet_rotation_completed(rotation_amount: int) -> void:
	total_rotations_seen += rotation_amount

	print("UpgradeManager total rotations seen: ", total_rotations_seen)

	for config in upgrade_button_configs:
		if config == null:
			continue

		if config.unlocked:
			continue

		if total_rotations_seen >= config.required_rotations:
			unlock_upgrade(config)


func unlock_upgrade(config: UpgradeButtonConfig) -> void:
	config.unlocked = true

	var button := get_node_or_null(config.button_path) as Button

	if button == null:
		push_warning("Could not unlock upgrade because button path is invalid: " + str(config.button_path))
		return

	button.disabled = false
	button.text = "Speed +" + str(config.spin_increase_amount)


func on_upgrade_button_pressed(node_path: NodePath) -> void:
	
	var button = get_node_or_null(node_path) as Button
	
	if not button_to_config.has(button):
		push_warning("Pressed button has no upgrade config.")
		return

	var config: UpgradeButtonConfig = button_to_config[button]

	if config == null:
		return

	if config.purchased:
		return

	if not config.unlocked:
		return

	var purchase_successful: bool = GameManagerObject.try_spend_currency(config.currency_cost)

	if purchase_successful == false:
		print("Not enough currency.")
		return

	planet_orbit.increase_base_spin_per_second(config.spin_increase_amount)

	config.purchased = true
