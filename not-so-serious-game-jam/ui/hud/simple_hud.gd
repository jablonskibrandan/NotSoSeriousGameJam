extends CanvasLayer
class_name SimpleHUD

@onready var stats_label: Label = %StatsLabel
@onready var upgrades_container: VBoxContainer = %UpgradesContainer

var _game_data: GameData = null
var _upgrade_manager: UpgradeManager = null

var _button_configs: Dictionary = {}

func _ready() -> void:
	# Await one frame to guarantee that siblings have registered in the scene tree
	await get_tree().process_frame
	
	var parent := get_parent()
	if parent:
		var manager := parent.get_node_or_null("UpgradeManager") as UpgradeManager
		var gd := parent.get_node_or_null("GameData") as GameData
		if manager and gd:
			initialize(gd, manager)

func initialize(p_game_data: GameData, p_upgrade_manager: UpgradeManager) -> void:
	_game_data = p_game_data
	_upgrade_manager = p_upgrade_manager
	
	_rebuild_upgrades_list()
	_update_hud_display()

func _process(delta: float) -> void:
	_update_hud_display()

func _update_hud_display() -> void:
	if _game_data == null:
		return
		
	var rad_speed := _game_data._base_spin
	var spin_input := _upgrade_manager.spin_input if _upgrade_manager else null
	if spin_input and spin_input._is_momentum_enabled:
		rad_speed += spin_input._momentum
		
	var rps := rad_speed / (2.0 * PI)
	var cash := GameManagerObject.current_currency
	var days := GameManagerObject.current_year_length
	var christmases := GameManagerObject.game_jam_days_celebrated
	
	stats_label.text = "Rotational Speed: %.2f rev/s\nMoney: $%d\nDays until Christmas: %d\nChristmases Celebrated: %d" % [rps, cash, days, christmases]
	
	for button_obj: Variant in _button_configs.keys():
		var btn := button_obj as Button
		var config := _button_configs[btn] as UpgradeButtonConfig
		if btn and config:
			if not config.is_unlocked:
				btn.disabled = true
				btn.text = "Locked"
			else:
				btn.disabled = false
				btn.text = "Buy: $%d" % config.currency_cost
				
				if cash < config.currency_cost:
					btn.disabled = true
					btn.text += " (Broke)"

func _rebuild_upgrades_list() -> void:
	for child in upgrades_container.get_children():
		child.queue_free()
		
	_button_configs.clear()
	
	if _upgrade_manager == null:
		return
		
	for config: UpgradeButtonConfig in _upgrade_manager.upgrade_button_configs:
		if config == null:
			continue
			
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(350.0, 40.0)
		upgrades_container.add_child(row)
		
		var info_lbl := Label.new()
		info_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_lbl.text = "%s (Owned: %d)\n%s" % [config.display_name, config.purchased_count, config.description]
		row.add_child(info_lbl)
		
		var buy_btn := Button.new()
		buy_btn.custom_minimum_size = Vector2(100.0, 30.0)
		buy_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(buy_btn)
		
		_button_configs[buy_btn] = config
		buy_btn.pressed.connect(_on_upgrade_button_pressed.bind(buy_btn))
		
	_update_hud_display()

func _on_upgrade_button_pressed(btn: Button) -> void:
	if not _button_configs.has(btn):
		return
		
	var config := _button_configs[btn] as UpgradeButtonConfig
	if config == null:
		return
		
	if GameManagerObject.try_spend_currency(config.currency_cost):
		_upgrade_manager.apply_upgrade(config)
		_upgrade_manager.register_purchase(config)
		_upgrade_manager.update_all_unlocks()
		
		_rebuild_upgrades_list()
