extends CanvasLayer
class_name SimpleHUD

const UPGRADE_CARD_SCENE: PackedScene = preload("res://ui/hud/upgrade_card.tscn")

@onready var stats_label: Label = %StatsLabel
@onready var upgrades_container: VBoxContainer = %UpgradesContainer

var _game_data: GameData = null
var _upgrade_manager: UpgradeManager = null

# Map UpgradeButtonConfig to their corresponding instantiated UpgradeCard node
var _card_nodes: Dictionary = {}

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
	
	for config: UpgradeButtonConfig in _card_nodes.keys():
		var card := _card_nodes[config] as UpgradeCard
		if is_instance_valid(card):
			card.update_status(cash)

func _rebuild_upgrades_list() -> void:
	for child in upgrades_container.get_children():
		child.queue_free()
		
	_card_nodes.clear()
	
	if _upgrade_manager == null:
		return
		
	for config: UpgradeButtonConfig in _upgrade_manager.upgrade_button_configs:
		if config == null:
			continue
			
		var card := UPGRADE_CARD_SCENE.instantiate() as UpgradeCard
		upgrades_container.add_child(card)
		card.setup(config, _on_upgrade_button_pressed.bind(config))
		_card_nodes[config] = card
		
	_update_hud_display()

func _on_upgrade_button_pressed(config: UpgradeButtonConfig) -> void:
	if config == null:
		return
		
	if GameManagerObject.try_spend_currency(config.currency_cost):
		_upgrade_manager.apply_upgrade(config)
		_upgrade_manager.register_purchase(config)
		_upgrade_manager.update_all_unlocks()
		
		_rebuild_upgrades_list()
