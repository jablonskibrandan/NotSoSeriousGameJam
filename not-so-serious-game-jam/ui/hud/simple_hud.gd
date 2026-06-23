extends CanvasLayer
class_name SimpleHUD

const UPGRADE_CARD_SCENE: PackedScene = preload("res://ui/hud/upgrade_card.tscn")

@onready var speed_value: Label = %SpeedValue
@onready var cash_value: Label = %CashValue
@onready var days_value: Label = %DaysValue
@onready var celebrated_value: Label = %CelebratedValue

@onready var stats_panel: PanelContainer = %StatsPanel
@onready var upgrades_container: VBoxContainer = %UpgradesContainer
@onready var tooltip_panel: PanelContainer = %TooltipPanel
@onready var tooltip_title: Label = %TooltipTitle
@onready var tooltip_desc: Label = %TooltipDesc

@export var game_data: GameData = null
@export var upgrade_manager: UpgradeManager = null
@export var floating_font: FontFile = preload("res://Assets/fonts/kidspace/MOKidspace-Trial.ttf")

var _card_nodes: Dictionary = {}

var _current_cash: int = 0
var _current_days: int = 0
var _current_christmases: int = 0
var _current_rps: float = 0.0
var _hovered_config: UpgradeButtonConfig = null

# Juice & Shake Tweens
var _planet_tween: Tween = null
var _stats_tween: Tween = null

func _ready() -> void:
	await get_tree().process_frame
	
	if game_data == null or upgrade_manager == null:
		var parent := get_parent()
		if parent:
			if upgrade_manager == null:
				upgrade_manager = parent.get_node_or_null("UpgradeManager") as UpgradeManager
				if upgrade_manager == null:
					upgrade_manager = parent.get_node_or_null("(old)UpgradeManager") as UpgradeManager
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

func _process(delta: float) -> void:
	# Update stats
	if game_data:
		var rad_speed: float = game_data._base_spin
		var spin_input: SpinInput = upgrade_manager.spin_input if upgrade_manager else null
		if spin_input and spin_input._is_momentum_enabled:
			rad_speed += spin_input._momentum
			
		var rps: float = rad_speed / (2.0 * PI)
		if not is_equal_approx(rps, _current_rps):
			_current_rps = rps
			_update_stats_label()
			
	# Update custom mouse-following tooltip
	if tooltip_panel and tooltip_panel.visible and _hovered_config != null:
		var target_pos: Vector2 = get_viewport().get_mouse_position() + Vector2(15, 15)
		var viewport_size: Vector2 = get_viewport().get_visible_rect().size
		if target_pos.x + tooltip_panel.size.x > viewport_size.x:
			target_pos.x = get_viewport().get_mouse_position().x - tooltip_panel.size.x - 15
		if target_pos.y + tooltip_panel.size.y > viewport_size.y:
			target_pos.y = get_viewport().get_mouse_position().y - tooltip_panel.size.y - 15
			
		tooltip_panel.global_position = tooltip_panel.global_position.lerp(target_pos, 0.25)

func _update_stats_label() -> void:
	if speed_value:
		speed_value.text = "%.2f rev/s" % _current_rps
	if cash_value:
		cash_value.text = "$%d" % _current_cash
	if days_value:
		days_value.text = "%d" % _current_days
	if celebrated_value:
		celebrated_value.text = "%d" % _current_christmases

func _update_card_statuses() -> void:
	for config: UpgradeButtonConfig in _card_nodes.keys():
		var card := _card_nodes[config] as UpgradeCard
		if is_instance_valid(card):
			card.visible = true
			card.update_status(_current_cash)

func _rebuild_upgrades_list() -> void:
	if _card_nodes.is_empty():
		for child in upgrades_container.get_children():
			child.queue_free()
			
		_card_nodes.clear()
		
		if upgrade_manager == null:
			return
			
		for config: UpgradeButtonConfig in upgrade_manager.upgrade_button_configs:
			if config == null:
				continue
				
			var card: UpgradeCard = UPGRADE_CARD_SCENE.instantiate() as UpgradeCard
			upgrades_container.add_child(card)
			card.setup(config, _on_upgrade_button_pressed.bind(config))
			card.hovered.connect(_on_card_hovered)
			card.unhovered.connect(_on_card_unhovered)
			_card_nodes[config] = card
			
	_update_card_statuses()

func _on_upgrade_button_pressed(config: UpgradeButtonConfig) -> void:
	if config == null:
		return
		
	if GameManagerObject.try_spend_currency(config.currency_cost):
		var card: UpgradeCard = _card_nodes.get(config)
		if card:
			var btn: Button = card.buy_button
			var spawn_pos: Vector2 = btn.global_position + btn.size / 2.0
			
			# Spawns flying cost text
			spawn_floating_text(spawn_pos, "-$%d" % config.currency_cost, Color(0.95, 0.25, 0.25))
			
			# Spawns effect text
			var effect_text: String = ""
			match config.effect_type:
				UpgradeButtonConfig.EffectType.AUTO_SPIN:
					effect_text = "+%.1f deg/s" % config.spin_increase_amount
				UpgradeButtonConfig.EffectType.DRAG_STRENGTH:
					effect_text = "+%.1f Drag" % config.drag_strength_bonus
				UpgradeButtonConfig.EffectType.ACTIVE_SPIN_BOOST:
					effect_text = "+%.1f Boost" % config.active_spin_boost_amount
			if effect_text != "":
				get_tree().create_timer(0.12).timeout.connect(func() -> void:
					spawn_floating_text(spawn_pos, effect_text, Color(0.0, 0.96, 0.83))
				)
			
			# Spawns a satisfying golden burst of particles/symbols
			spawn_confetti_burst(spawn_pos)
				
		# Camera shake trigger for chaotic feedback
		var cam: Node3D = get_parent().get_node_or_null("OrbitCam") as Node3D
		if cam and cam.has_method("add_shake"):
			cam.call("add_shake", 0.4)
			
		# Squash & stretch bounce on 3D Earth planet node
		var planet: Node3D = get_parent().get_node_or_null("PlanetActor") as Node3D
		if planet:
			if _planet_tween and _planet_tween.is_valid():
				_planet_tween.kill()
			
			planet.scale = Vector3(1.05, 0.95, 1.05)
			_planet_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
			_planet_tween.tween_property(planet, "scale", Vector3(1.0, 1.0, 1.0), 0.6)
			
		upgrade_manager.apply_upgrade(config)
		upgrade_manager.register_purchase(config)
		upgrade_manager.update_all_unlocks()
		
		_update_card_statuses()

func spawn_confetti_burst(p_pos: Vector2) -> void:
	var symbols: Array[String] = ["$", "+", "*", "!", "UP", "SPIN"]
	for i in range(8):
		var label: Label = Label.new()
		label.text = symbols.pick_random()
		
		# Randomized golden/gold-orange/cyan colors matching the cosmic design system
		var rand_choice: float = randf()
		if rand_choice < 0.4:
			label.add_theme_color_override("font_color", Color(1.0, 0.75, 0.0)) # Bright Gold
		elif rand_choice < 0.8:
			label.add_theme_color_override("font_color", Color(1.0, 0.55, 0.0)) # Darker Amber/Orange
		else:
			label.add_theme_color_override("font_color", Color(0.0, 0.96, 0.83)) # Celestial Cyan
			
		if floating_font:
			label.add_theme_font_override("font", floating_font)
		label.add_theme_font_size_override("font_size", randi_range(16, 26))
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_constant_override("outline_size", 4)
		
		%FloatingTextContainer.add_child(label)
		label.reset_size()
		label.global_position = p_pos - label.size / 2.0
		label.pivot_offset = label.size / 2.0
		label.scale = Vector2(0.1, 0.1)
		
		var angle: float = randf_range(0.0, 2.0 * PI)
		var dist: float = randf_range(70.0, 130.0)
		var target_pos: Vector2 = label.global_position + Vector2(cos(angle), sin(angle)) * dist
		var random_rot: float = randf_range(-360.0, 360.0)
		
		var scale_tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		scale_tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.15)
		scale_tween.tween_property(label, "scale", Vector2(0.0, 0.0), randf_range(0.6, 0.9))
		
		var float_tween: Tween = create_tween().set_parallel(true)
		float_tween.tween_property(label, "global_position", target_pos, 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		float_tween.tween_property(label, "rotation_degrees", random_rot, 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		float_tween.chain().tween_callback(label.queue_free)

func spawn_floating_text(p_pos: Vector2, p_text: String, p_color: Color) -> void:
	var label: Label = Label.new()
	label.text = p_text
	label.add_theme_color_override("font_color", p_color)
	if floating_font:
		label.add_theme_font_override("font", floating_font)
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 6)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	%FloatingTextContainer.add_child(label)
	label.reset_size()
	label.global_position = p_pos - label.size / 2.0
	label.pivot_offset = label.size / 2.0
	label.scale = Vector2(0.2, 0.2)
	
	var angle: float = randf_range(-PI / 3.0, PI / 3.0) - PI / 2.0
	var dist: float = randf_range(110.0, 160.0)
	var target_pos: Vector2 = label.global_position + Vector2(cos(angle), sin(angle)) * dist
	var random_rot: float = randf_range(-140.0, 140.0)
	
	var scale_tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	scale_tween.tween_property(label, "scale", Vector2(1.3, 1.3), 0.15)
	scale_tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.1)
	
	var float_tween: Tween = create_tween().set_parallel(true)
	float_tween.tween_property(label, "global_position", target_pos, 1.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	float_tween.tween_property(label, "rotation_degrees", random_rot, 1.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	float_tween.tween_property(label, "modulate:a", 0.0, 1.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	float_tween.chain().tween_callback(label.queue_free)

func _on_card_hovered(config: UpgradeButtonConfig) -> void:
	_hovered_config = config
	tooltip_title.text = config.display_name
	tooltip_desc.text = config.description
	
	tooltip_panel.visible = true
	tooltip_panel.modulate.a = 0.0
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(tooltip_panel, "modulate:a", 1.0, 0.15)

func _on_card_unhovered() -> void:
	_hovered_config = null
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(tooltip_panel, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func() -> void:
		if _hovered_config == null:
			tooltip_panel.visible = false
	)

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

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_QUOTELEFT:
			var cheat_win := get_parent().get_node_or_null("CheatWindow") as Window
			if cheat_win:
				cheat_win.visible = not cheat_win.visible
				get_viewport().set_input_as_handled()
