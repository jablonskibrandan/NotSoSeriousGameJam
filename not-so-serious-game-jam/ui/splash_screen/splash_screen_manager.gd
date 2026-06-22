extends Control

@export var _initial_delay: float = 1.0
@export var _fade_out_time: float = 0.5

var _splash_screens: Array[SplashScreen] = []
var _current_screen: SplashScreen = null
var _is_finished: bool = false

@onready var _splash_screen_container: CenterContainer = $SplashScreenContainer
@onready var _fade_rect: ColorRect = $FadeRect


func _ready() -> void:
	GameManagerObject.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	_fade_rect.visible = true
	_fade_rect.modulate.a = 0.0

	for splash_screen in _splash_screen_container.get_children():
		splash_screen.hide()
		_splash_screens.push_back(splash_screen)
	
	# Small delay before starting first splash
	var timer = get_tree().create_timer(_initial_delay)
	timer.timeout.connect(func(): if not _is_finished: _start_splash_screen())


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("splash_skip"):
		_skip()


func _start_splash_screen() -> void:
	if _is_finished: return
	
	if _splash_screens.is_empty():
		_fade_and_hand_off()
	else:
		_current_screen = _splash_screens.pop_front()
		_current_screen.finished.connect(_on_screen_finished)
		_current_screen.start()


func _on_screen_finished() -> void:
	_current_screen = null
	_start_splash_screen()


func _skip() -> void:
	if _is_finished: return
	
	if _current_screen:
		_current_screen.skip()
	else:
		_fade_and_hand_off()


func _fade_and_hand_off() -> void:
	if _is_finished:
		return
	_is_finished = true
	set_process_input(false)

	var tween: Tween = create_tween()
	tween.tween_property(_fade_rect, "modulate:a", 1.0, _fade_out_time)
	await tween.finished

	Bus.splash_finished.emit()
