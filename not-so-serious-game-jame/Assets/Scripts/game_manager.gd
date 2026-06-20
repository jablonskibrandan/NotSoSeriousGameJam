# This is an autoloaded class. 

extends Node
class_name GameManager

const DAYS_IN_YEAR: int = 365
var current_year_length: int
var game_jam_days_celebrated: int
var current_currency: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_jam_days_celebrated = 0
	current_year_length = 365


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
	
func try_spend_currency(money_to_lose: int):
	if((current_currency - money_to_lose) >= 0 ):
		current_currency -= money_to_lose
	else:
	#TODO: Pop up a messaage that says "you ain't got enough money, fool" or something.
		pass
