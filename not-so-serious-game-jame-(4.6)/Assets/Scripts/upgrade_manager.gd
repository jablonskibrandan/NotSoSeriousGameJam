extends Node
class_name UpgradeManager

@export var planet_orbit: PlanetOrbit
@export var upgrade_button_configs: Array[UpgradeButtonConfig] = []

var total_rotations_seen: int = 0
var button_to_config: Dictionary = {}
var purchased_counts_by_item_id: Dictionary = {}


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

	update_all_unlocks()


func _process(delta: float) -> void:
	update_cooldowns(delta)


func on_planet_rotation_completed(rotation_amount: int) -> void:
	total_rotations_seen += rotation_amount
	update_all_unlocks()

# I'm not sure if this is the way we really want to do it. Works for now... 
func update_all_unlocks() -> void:
	for config in upgrade_button_configs:
		if config == null:
			continue

		if config.unlocked:
			continue

		if is_unlock_requirement_met(config):
			unlock_upgrade(config)


func is_unlock_requirement_met(config: UpgradeButtonConfig) -> bool:
	match config.unlock_type:
		UpgradeButtonConfig.UnlockType.ROTATIONS:
			return total_rotations_seen >= config.required_amount

		UpgradeButtonConfig.UnlockType.JAM_DAYS:
			return GameManagerObject.game_jam_days_celebrated >= config.required_amount

		UpgradeButtonConfig.UnlockType.PURCHASE_COUNT:
			return get_purchased_count(config.required_item_id) >= config.required_amount

		#TODO: Update later, add more, etc. 
		UpgradeButtonConfig.UnlockType.TIMED_RANDOM:
			return false

		_:
			return false


func unlock_upgrade(config: UpgradeButtonConfig) -> void:
	config.unlocked = true

	var button := get_node_or_null(config.button_path) as Button

	if button == null:
		push_warning("Could not unlock upgrade because button path is invalid: " + str(config.button_path))
		return

	button.disabled = false
	button.text = config.display_name + " $" + str(config.currency_cost)


func on_upgrade_button_pressed(node_path: NodePath) -> void:
	var button: Button = get_node_or_null(node_path) as Button
	 
	if not button_to_config.has(button):
		push_warning("Pressed button has no upgrade config.")
		return

	var config: UpgradeButtonConfig = button_to_config[button]

	if config == null:
		return

	if not config.unlocked:
		return

	if config.cooldown_remaining > 0.0:
		print("Upgrade is on cooldown.")
		return

	if GameManagerObject.try_spend_currency(config.currency_cost) == false:
		print("Not enough currency.")
		return

	apply_upgrade(config)
	register_purchase(config)

	update_button_after_purchase(config, button)
	update_all_unlocks()


func apply_upgrade(config: UpgradeButtonConfig) -> void:
	match config.effect_type:
		UpgradeButtonConfig.EffectType.AUTO_SPIN:
			planet_orbit.increase_base_spin_per_second(config.spin_increase_amount)

		UpgradeButtonConfig.EffectType.DRAG_STRENGTH:
			planet_orbit.increase_drag_spin_strength(config.drag_strength_bonus)

		UpgradeButtonConfig.EffectType.ACTIVE_SPIN_BOOST:
			planet_orbit.add_active_spin_boost(config.active_spin_boost_amount)

			if config.cooldown_seconds > 0.0:
				config.cooldown_remaining = config.cooldown_seconds


func register_purchase(config: UpgradeButtonConfig) -> void:
	config.purchased_count += 1

	if config.item_id == "":
		return

	if not purchased_counts_by_item_id.has(config.item_id):
		purchased_counts_by_item_id[config.item_id] = 0

	purchased_counts_by_item_id[config.item_id] += 1


func get_purchased_count(item_id: String) -> int:
	if not purchased_counts_by_item_id.has(item_id):
		return 0

	return int(purchased_counts_by_item_id[item_id])


func update_button_after_purchase(config: UpgradeButtonConfig, button: Button) -> void:
	if config.effect_type == UpgradeButtonConfig.EffectType.ACTIVE_SPIN_BOOST:
		if config.cooldown_seconds > 0.0:
			button.disabled = true
			button.text = config.display_name + " Cooling Down"
		return

	button.text = config.display_name + " Bought: " + str(config.purchased_count)


func update_cooldowns(delta: float) -> void:
	for config in upgrade_button_configs:
		if config == null:
			continue

		if config.cooldown_remaining <= 0.0:
			continue

		config.cooldown_remaining -= delta

		var button := get_node_or_null(config.button_path) as Button

		if button == null:
			continue

		if config.cooldown_remaining > 0.0:
			button.disabled = true
			button.text = config.display_name + " " + str(ceil(config.cooldown_remaining))
		else:
			config.cooldown_remaining = 0.0
			button.disabled = false
			button.text = config.display_name + " $" + str(config.currency_cost)
