# This is an autoloaded class. 

extends Node
class_name GameManager

signal currency_changed(current_currency: int)

const DAYS_IN_YEAR: int = 365
var current_year_length: int
var game_jam_days_celebrated: int
var current_currency: int
var rotation_count: int 

var total_rotations_seen: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_jam_days_celebrated = 0
	current_year_length = 365


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (current_year_length <= 0): 
		game_jam_days_celebrated += 1
		current_year_length = DAYS_IN_YEAR
	
	if (current_currency <= 0):
		current_currency = 0
	
func shorten_year_length(days: int ): 
	current_year_length -= days
	
func celebrate_another_game_jam_day() -> void:
	game_jam_days_celebrated += 1

func add_to_current_currency(money_to_add: int):
	current_currency += money_to_add

func try_spend_currency(amount: int) -> bool:
	if current_currency < amount:
		return false

	current_currency -= amount
	currency_changed.emit(current_currency)
	return true
	
func on_planet_rotation_completed(rotation_amount: int) -> void:
	total_rotations_seen += rotation_amount

	print("Planet rotated. Total seen by UpgradeManager: ", total_rotations_seen)

	
