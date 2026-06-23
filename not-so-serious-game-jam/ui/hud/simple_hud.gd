extends CanvasLayer
class_name SimpleHUD

const UPGRADE_CARD_SCENE: PackedScene = preload("res://ui/hud/upgrade_card.tscn")

@onready var stats_label: Label = %StatsLabel
@onready var upgrades_container: VBoxContainer = %UpgradesContainer

@export var game_data: GameData = null
@export var upgrade_manager: UpgradeManager = null

var _card_nodes: Dictionary = {}

var _current_cash: int = 0
var _current_days: int = 0
var _current_christmases: int = 0
var _current_rps: float = 0.0

func _ready() -> void:
	await get_tree().process_frame
	
	if game_data == null or upgrade_manager == null:
		var parent := get_parent()
		if parent:
			if upgrade_manager == null:
				upgrade_manager = parent.get_node_or_null("UpgradeManager") as UpgradeManager
			if game_data == null:
				game_data = parent.get_node_or_null("GameData") as GameData
	
	if game_data and upgrade_manager:
		initialize(game_data, upgrade_manager)

func initialize(p_game_data: GameData, p_upgrade_manager: UpgradeManager) -> void:
	game_data = p_game_data
	upgrade_manager = p_upgrade_manager
	
	_current_cash = GameManagerObject.current_currency
	_current_days = GameManagerObject.current_year_length
	_current_christmases = GameManagerObject.game_jam_days_celebrated
	
	if not GameManagerObject.currency_changed.is_connected(_on_currency_changed):
		GameManagerObject.currency_changed.connect(_on_currency_changed)
	if not GameManagerObject.year_length_changed.is_connected(_on_year_length_changed):
		GameManagerObject.year_length_changed.connect(_on_year_length_changed)
	if not GameManagerObject.days_celebrated_changed.is_connected(_on_days_celebrated_changed):
		GameManagerObject.days_celebrated_changed.connect(_on_days_celebrated_changed)
	if not GameManagerObject.rotations_completed.is_connected(_on_rotations_completed):
		GameManagerObject.rotations_completed.connect(_on_rotations_completed)
	
	_rebuild_upgrades_list()
	_update_stats_label()

func _process(_delta: float) -> void:
	if game_data == null:
		return
		
	var rad_speed := game_data._base_spin
	var spin_input := upgrade_manager.spin_input if upgrade_manager else null
	if spin_input and spin_input._is_momentum_enabled:
		rad_speed += spin_input._momentum
		
	var rps := rad_speed / (2.0 * PI)
	if not is_equal_approx(rps, _current_rps):
		_current_rps = rps
		_update_stats_label()

func _update_stats_label() -> void:
	stats_label.text = "Rotational Speed: %.2f rev/s\nMoney: $%d\nDays until Christmas: %d\nChristmases Celebrated: %d" % [
		_current_rps, _current_cash, _current_days, _current_christmases
	]

func _update_card_statuses() -> void:
	for config: UpgradeButtonConfig in _card_nodes.keys():
		var card := _card_nodes[config] as UpgradeCard
		if is_instance_valid(card):
			card.update_status(_current_cash)

func _rebuild_upgrades_list() -> void:
	for child in upgrades_container.get_children():
		child.queue_free()
		
	_card_nodes.clear()
	
	if upgrade_manager == null:
		return
		
	for config: UpgradeButtonConfig in upgrade_manager.upgrade_button_configs:
		if config == null:
			continue
			
		var card := UPGRADE_CARD_SCENE.instantiate() as UpgradeCard
		upgrades_container.add_child(card)
		card.setup(config, _on_upgrade_button_pressed.bind(config))
		_card_nodes[config] = card
		
	_update_card_statuses()

func _on_upgrade_button_pressed(config: UpgradeButtonConfig) -> void:
	if config == null:
		return
		
	if GameManagerObject.try_spend_currency(config.currency_cost):
		upgrade_manager.apply_upgrade(config)
		upgrade_manager.register_purchase(config)
		upgrade_manager.update_all_unlocks()
		
		_rebuild_upgrades_list()

func _on_currency_changed(new_currency: int) -> void:
	_current_cash = new_currency
	_update_stats_label()
	_update_card_statuses()

func _on_year_length_changed(new_length: int) -> void:
	_current_days = new_length
	_update_stats_label()

func _on_days_celebrated_changed(new_celebrated: int) -> void:
	_current_christmases = new_celebrated
	_update_stats_label()
	_update_card_statuses()

func _on_rotations_completed(_total_rotations: int) -> void:
	_update_card_statuses()
