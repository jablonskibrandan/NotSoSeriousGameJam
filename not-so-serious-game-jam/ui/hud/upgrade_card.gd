extends PanelContainer
class_name UpgradeCard

const DEFAULT_ICON: Texture2D = preload("res://icon.svg")

@onready var icon_rect: TextureRect = %IconRect
@onready var title_label: Label = %TitleLabel
@onready var desc_label: Label = %DescLabel
@onready var buy_button: Button = %BuyButton

var _config: UpgradeButtonConfig = null

func setup(p_config: UpgradeButtonConfig, p_on_pressed: Callable) -> void:
	_config = p_config
	
	icon_rect.texture = _config.icon if _config.icon != null else DEFAULT_ICON
	title_label.text = "%s (Owned: %d)" % [_config.display_name, _config.purchased_count]
	desc_label.text = _config.description
	
	if buy_button.pressed.is_connected(p_on_pressed):
		buy_button.pressed.disconnect(p_on_pressed)
	buy_button.pressed.connect(p_on_pressed)

func update_status(current_cash: int) -> void:
	if _config == null:
		return
		
	if not _config.is_unlocked:
		buy_button.disabled = true
		buy_button.text = "Locked"
	else:
		buy_button.disabled = false
		buy_button.text = "Buy: $%d" % _config.currency_cost
		
		if current_cash < _config.currency_cost:
			buy_button.disabled = true
			buy_button.text += " (Broke)"
