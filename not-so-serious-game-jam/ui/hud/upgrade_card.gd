extends MarginContainer
class_name UpgradeCard

signal hovered(config: UpgradeButtonConfig)
signal unhovered()

@export var default_icon: Texture2D = preload("res://icon.svg")
@export var use_custom_icons: bool = false

@onready var inner_panel: PanelContainer = %InnerPanel
@onready var icon_rect: TextureRect = %IconRect
@onready var title_label: Label = %TitleLabel
@onready var stats_label: Label = %StatsLabel
@onready var buy_button: Button = %BuyButton

var _config: UpgradeButtonConfig = null
var _on_pressed_callback: Callable
var _is_hovered: bool = false
var _hover_tween: Tween = null

func setup(p_config: UpgradeButtonConfig, p_on_pressed: Callable) -> void:
	_config = p_config
	_on_pressed_callback = p_on_pressed
	
	if use_custom_icons and _config.icon != null:
		icon_rect.texture = _config.icon
	else:
		icon_rect.texture = default_icon
		
	title_label.text = _config.display_name
	
	_update_stats_display()
	
	if buy_button.pressed.is_connected(_on_buy_button_pressed):
		buy_button.pressed.disconnect(_on_buy_button_pressed)
	buy_button.pressed.connect(_on_buy_button_pressed)

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	resized.connect(_update_pivot)
	_update_pivot()

func _update_pivot() -> void:
	if inner_panel:
		inner_panel.pivot_offset = inner_panel.size / 2.0
	if buy_button:
		buy_button.pivot_offset = buy_button.size / 2.0

func _update_stats_display() -> void:
	if _config == null:
		return
		
	var force_text: String = ""
	match _config.effect_type:
		UpgradeButtonConfig.EffectType.AUTO_SPIN:
			force_text = "Spin force: +%.1f deg/s" % _config.spin_increase_amount
		UpgradeButtonConfig.EffectType.DRAG_STRENGTH:
			force_text = "Drag strength: +%.1f" % _config.drag_strength_bonus
		UpgradeButtonConfig.EffectType.ACTIVE_SPIN_BOOST:
			force_text = "Active boost: +%.1f" % _config.active_spin_boost_amount
			
	var parent_hud: Node = get_parent()
	while parent_hud and not parent_hud is SimpleHUD:
		parent_hud = parent_hud.get_parent()
		
	var rotations_val: int = 0
	if parent_hud is SimpleHUD and parent_hud.upgrade_manager != null:
		var manager: UpgradeManager = parent_hud.upgrade_manager
		if manager.has_method("get_rotations_generated"):
			rotations_val = int(manager.call("get_rotations_generated", _config))
			
	stats_label.text = "Owned: %d\n%s\nRotations: %d" % [
		_config.purchased_count, force_text, rotations_val
	]

func update_status(current_cash: int) -> void:
	if _config == null:
		return
		
	_update_stats_display()
	
	if not _config.is_unlocked:
		buy_button.disabled = true
		buy_button.text = "Locked"
	else:
		buy_button.disabled = false
		buy_button.text = "$%d" % _config.currency_cost
		
		if current_cash < _config.currency_cost:
			buy_button.disabled = true

func _on_buy_button_pressed() -> void:
	MusicManager.play_ui_click()
	
	if _hover_tween and _hover_tween.is_valid():
		_hover_tween.kill()
		
	_hover_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	_hover_tween.tween_property(buy_button, "scale", Vector2(0.85, 0.85), 0.05)
	_hover_tween.tween_property(buy_button, "scale", Vector2(1.08 if _is_hovered else 1.0, 1.08 if _is_hovered else 1.0), 0.1)
	
	if _on_pressed_callback.is_valid():
		_on_pressed_callback.call()

func _on_mouse_entered() -> void:
	_update_hover_state(true)

func _on_mouse_exited() -> void:
	_update_hover_state(false)

func _update_hover_state(p_should_hover: bool) -> void:
	var is_actually_inside := get_global_rect().has_point(get_global_mouse_position())
	
	if not p_should_hover and is_actually_inside:
		return
		
	if p_should_hover == _is_hovered:
		return
		
	_is_hovered = p_should_hover
	_update_pivot()
	
	if _hover_tween and _hover_tween.is_valid():
		_hover_tween.kill()
		
	_hover_tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT)
	
	if _is_hovered:
		_hover_tween.set_trans(Tween.TRANS_BACK)
		_hover_tween.tween_property(inner_panel, "scale", Vector2(1.03, 1.03), 0.2)
		_hover_tween.tween_property(buy_button, "scale", Vector2(1.08, 1.08), 0.2)
		MusicManager.play_ui_hover()
		hovered.emit(_config)
	else:
		_hover_tween.set_trans(Tween.TRANS_SINE)
		_hover_tween.tween_property(inner_panel, "scale", Vector2(1.0, 1.0), 0.15)
		_hover_tween.tween_property(buy_button, "scale", Vector2(1.0, 1.0), 0.15)
		unhovered.emit()
