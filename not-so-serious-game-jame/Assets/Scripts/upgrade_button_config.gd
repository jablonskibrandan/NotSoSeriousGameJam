extends Resource
class_name UpgradeButtonConfig

@export var required_rotations: int = 0
@export var button_path: NodePath

@export var spin_increase_amount: float = 0.0
@export var currency_cost: int = 0

var unlocked: bool = false
var purchased: bool = false
