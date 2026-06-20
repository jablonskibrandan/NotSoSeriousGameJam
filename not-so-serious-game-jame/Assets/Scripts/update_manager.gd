extends Node
class_name UpgradeManager

@export var planet_orbit: PlanetOrbit
@export var upgrade_button_configs: Array[UpgradeButtonConfig] = []


func _ready() -> void:
	if planet_orbit == null:
		push_error("UpgradeManager needs a PlanetOrbit assigned.")
		return

	planet_orbit.rotation_completed.connect(_on_planet_rotation_completed)

	for config in upgrade_button_configs:
		if config == null:
			continue

		var button := get_node_or_null(config.button_path) as Button

		if button == null:
			push_warning("Upgrade config has no valid button path.")
			continue

		button.disabled = true
		button.text = "Locked"
		button.pressed.connect(_on_upgrade_button_pressed.bind(config))


func _on_planet_rotation_completed(total_rotations: int) -> void:
	for config in upgrade_button_configs:
		if config == null:
			continue

		if config.unlocked:
			continue

		if total_rotations >= config.required_rotations:
			unlock_upgrade(config)


func unlock_upgrade(config: UpgradeButtonConfig) -> void:
	config.unlocked = true

	var button := get_node_or_null(config.button_path) as Button

	if button == null:
		return

	button.disabled = false
	button.text = "Speed +" + str(config.spin_increase_amount)


func _on_upgrade_button_pressed(config: UpgradeButtonConfig) -> void:
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

	var button := get_node_or_null(config.button_path) as Button

	if button != null:
		button.disabled = true
		button.text = "Purchased"
