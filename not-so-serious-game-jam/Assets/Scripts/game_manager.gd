extends Node
class_name GameManager

enum GameState {
	MAIN_MENU,
	LOADING,
	PLAYING,
	PAUSED,
	ENDING,
	GAMEOVER,
}

signal currency_changed(current_currency: int)
signal state_changed(new_state: GameState)
signal year_length_changed(current_year_length: int)
signal days_celebrated_changed(game_jam_days_celebrated: int)
signal rotations_completed(total_rotations_seen: int)

const DAYS_IN_YEAR: int = 365
var current_year_length: int
var game_jam_days_celebrated: int
var current_currency: int
var rotation_count: int 

var total_rotations_seen: int = 0
var current_state: GameState = GameState.MAIN_MENU
var is_input_locked: bool = false

func _ready() -> void:
	game_jam_days_celebrated = 0
	current_year_length = 365


func shorten_year_length(days: int) -> void: 
	current_year_length -= days
	while current_year_length <= 0:
		game_jam_days_celebrated += 1
		current_year_length += DAYS_IN_YEAR
		days_celebrated_changed.emit(game_jam_days_celebrated)
	
	year_length_changed.emit(current_year_length)
	
func celebrate_another_game_jam_day() -> void:
	game_jam_days_celebrated += 1
	days_celebrated_changed.emit(game_jam_days_celebrated)

func add_to_current_currency(money_to_add: int) -> void:
	current_currency += money_to_add
	currency_changed.emit(current_currency)



func try_spend_currency(amount: int) -> bool:
	if current_currency < amount:
		return false

	current_currency -= amount
	currency_changed.emit(current_currency)
	return true
	
func on_planet_rotation_completed(rotation_amount: int) -> void:
	total_rotations_seen += rotation_amount
	rotations_completed.emit(total_rotations_seen)

func set_state(new_state: GameState) -> void:
	if current_state == new_state:
		return
		
	current_state = new_state
	state_changed.emit(current_state)
	
	match current_state:
		GameState.PLAYING:
			_enter_playing_state()
		GameState.PAUSED:
			_enter_paused_state()
		GameState.MAIN_MENU:
			_enter_main_menu_state()
		GameState.LOADING:
			_enter_loading_state()
		GameState.ENDING:
			_enter_ending_state()
		GameState.GAMEOVER:
			_enter_gameover_state()

func set_mouse_mode(mode: Input.MouseMode) -> void:
	if Input.mouse_mode != mode:
		Input.mouse_mode = mode

func _enter_playing_state() -> void:
	Engine.time_scale = 1.0
	is_input_locked = false
	set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _enter_paused_state() -> void:
	Engine.time_scale = 1.0
	is_input_locked = true
	set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _enter_main_menu_state() -> void:
	is_input_locked = true
	set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _enter_loading_state() -> void:
	is_input_locked = true
	set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _enter_ending_state() -> void:
	is_input_locked = true
	set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _enter_gameover_state() -> void:
	is_input_locked = true
	set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func reset_game_state() -> void:
	game_jam_days_celebrated = 0
	current_year_length = DAYS_IN_YEAR
	current_currency = 0
	rotation_count = 0
	total_rotations_seen = 0
	is_input_locked = false
	currency_changed.emit(current_currency)
	year_length_changed.emit(current_year_length)
	days_celebrated_changed.emit(game_jam_days_celebrated)



	
