@icon("res://Assets/icons/icon_assets/addons/at-icons/node/wrench.svg")
extends Node
class_name UpgradeManager

@export var game_data: GameData
@export var spin_input: SpinInput

@export var upgrade_button_configs: Array[UpgradeButtonConfig] = []
@export var drag_strength_multiplier: float = 0.2

var button_to_config: Dictionary = {}
var purchased_counts_by_item_id: Dictionary = {}
var rotations_generated: Dictionary = {}

func _ready() -> void:
		
	for config: UpgradeButtonConfig in upgrade_button_configs:
		if config == null:
			continue
		config.purchased_count = 0
		config.is_unlocked = false
		config.cooldown_remaining = 0.0

	update_all_unlocks()

func _process(delta: float) -> void:
	update_cooldowns(delta)
	update_all_unlocks()
	_update_rotations_generated(delta)

func get_rotations_generated(config: UpgradeButtonConfig) -> float:
	if rotations_generated.has(config):
		return rotations_generated[config]
	return 0.0

func _update_rotations_generated(delta: float) -> void:
	if game_data == null:
		return
	for config: UpgradeButtonConfig in upgrade_button_configs:
		if config == null or config.purchased_count == 0:
			continue
		if config.effect_type == UpgradeButtonConfig.EffectType.AUTO_SPIN:
			if not rotations_generated.has(config):
				rotations_generated[config] = 0.0
			var rps := deg_to_rad(config.spin_increase_amount) * config.purchased_count / (2.0 * PI)
			rotations_generated[config] += rps * delta



func update_all_unlocks() -> void:
	for config: UpgradeButtonConfig in upgrade_button_configs:
		if config == null:
			continue

		if config.is_unlocked:
			continue

		if is_unlock_requirement_met(config):
			unlock_upgrade(config)

func is_unlock_requirement_met(config: UpgradeButtonConfig) -> bool:
	match config.unlock_type:
		UpgradeButtonConfig.UnlockType.ROTATIONS:
			# Use GameManagerObject's global rotations count to support decoupled scene loading
			return GameManagerObject.total_rotations_seen >= config.required_amount

		UpgradeButtonConfig.UnlockType.JAM_DAYS:
			return GameManagerObject.game_jam_days_celebrated >= config.required_amount

		UpgradeButtonConfig.UnlockType.PURCHASE_COUNT:
			return get_purchased_count(config.required_item_id) >= config.required_amount

		UpgradeButtonConfig.UnlockType.TIMED_RANDOM:
			return false

		_:
			return false

func unlock_upgrade(config: UpgradeButtonConfig) -> void:
	config.is_unlocked = true

func apply_upgrade(config: UpgradeButtonConfig) -> void:
	match config.effect_type:
		UpgradeButtonConfig.EffectType.AUTO_SPIN:
			if game_data != null:
				var rad_increase := deg_to_rad(config.spin_increase_amount)
				game_data.increase_base_spin(rad_increase)

		UpgradeButtonConfig.EffectType.DRAG_STRENGTH:
			if spin_input != null:
				spin_input.drag_sensitivity += config.drag_strength_bonus * drag_strength_multiplier
				spin_input.drag_force += config.drag_strength_bonus * drag_strength_multiplier

		UpgradeButtonConfig.EffectType.ACTIVE_SPIN_BOOST:
			if spin_input != null:
				spin_input.add_active_spin_boost(config.active_spin_boost_amount)

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

func update_cooldowns(delta: float) -> void:
	for config: UpgradeButtonConfig in upgrade_button_configs:
		if config == null:
			continue

		if config.cooldown_remaining <= 0.0:
			continue

		config.cooldown_remaining -= delta
		if config.cooldown_remaining < 0.0:
			config.cooldown_remaining = 0.0
