extends Resource
class_name UpgradeButtonConfig

enum UnlockType {
	ROTATIONS,
	JAM_DAYS,
	PURCHASE_COUNT,
	TIMED_RANDOM
}

enum EffectType {
	AUTO_SPIN,
	DRAG_STRENGTH,
	ACTIVE_SPIN_BOOST
}

@export_group("UI")
@export var button_path: NodePath
@export var display_name: String = "Upgrade"
@export_multiline var description: String = ""
@export var icon: Texture2D

@export_group("Unlock")
@export var unlock_type: UnlockType = UnlockType.ROTATIONS
@export var required_amount: int = 0
@export var required_item_id: String = ""

@export_group("Purchase")
@export var item_id: String = ""
@export var currency_cost: int = 0

@export_group("Effect")
@export var effect_type: EffectType = EffectType.AUTO_SPIN
@export var spin_increase_amount: float = 0.0
@export var drag_strength_bonus: float = 0.0
@export var active_spin_boost_amount: float = 0.0
@export var cooldown_seconds: float = 0.0

var is_unlocked: bool = false
var purchased_count: int = 0
var cooldown_remaining: float = 0.0
