extends Node

@export var start_level_path: String = "res://Assets/planet2/test_scene_2.tscn"
@export var skip_splash_screen: bool = false

var _main_scene: Node
var _level_container: Node3D
var _splash_layer: CanvasLayer
var _menu_layer: CanvasLayer
var _main_menu: Control

var _pause_menu: Control
var _options_menu: Control
var _credits_menu: Control

var _confirm_dialog: Control

var _fade_rect: ColorRect

var _menu_stack: Array[Control] = []
var _pending_confirm_action: Callable

const _FADE_DURATION := 0.5
const _CONFIRM_SCENE: PackedScene = preload("res://ui/menus/shared/confirmation_dialog.tscn")

var _is_transitioning: bool = false


func is_confirm_dialog_visible() -> bool:
	return is_instance_valid(_confirm_dialog) and _confirm_dialog.visible


func initialize(main_scene: Node) -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_main_scene = main_scene
	_level_container = main_scene.get_node("LevelContainer")
	_menu_layer = main_scene.get_node("MainMenuLayer")
	_main_menu = _menu_layer.get_node("MainMenu")

	if main_scene.has_node("SplashScreenLayer"):
		_splash_layer = main_scene.get_node("SplashScreenLayer")

	if main_scene.has_node("OptionsLayer"):
		_options_menu = main_scene.get_node("OptionsLayer/OptionsMenu")
	if main_scene.has_node("CreditsLayer"):
		_credits_menu = main_scene.get_node("CreditsLayer/CreditsMenu")
	if main_scene.has_node("PauseLayer"):
		_pause_menu = main_scene.get_node("PauseLayer/PauseMenu")

	_fade_rect = main_scene.get_node("FadeLayer/FadeRect")

	_connect_menu_signals()
	
	if skip_splash_screen or not is_instance_valid(_splash_layer):
		if is_instance_valid(_splash_layer):
			_splash_layer.queue_free()
		_show_main_menu()
	else:
		Bus.splash_finished.connect(_on_splash_finished)


func _on_splash_finished() -> void:
	if is_instance_valid(_splash_layer):
		_splash_layer.queue_free()
	_show_main_menu()


func _connect_menu_signals() -> void:
	if _main_menu:
		if not _main_menu.start_requested.is_connected(_on_start_requested):
			_main_menu.start_requested.connect(_on_start_requested)
		if not _main_menu.options_requested.is_connected(_show_options_menu):
			_main_menu.options_requested.connect(_show_options_menu)
		if not _main_menu.credits_requested.is_connected(_show_credits_menu):
			_main_menu.credits_requested.connect(_show_credits_menu)
		if not _main_menu.exit_requested.is_connected(_on_exit_requested):
			_main_menu.exit_requested.connect(_on_exit_requested)

	if _options_menu and not _options_menu.close_requested.is_connected(_pop_menu):
		_options_menu.close_requested.connect(_pop_menu)
	if _credits_menu and not _credits_menu.close_requested.is_connected(_pop_menu):
		_credits_menu.close_requested.connect(_pop_menu)
	if _pause_menu and not _pause_menu.resume_requested.is_connected(_toggle_pause):
		_pause_menu.resume_requested.connect(_toggle_pause)
		_pause_menu.options_requested.connect(_show_options_menu)
		_pause_menu.main_menu_requested.connect(_on_main_menu_from_pause)
		_pause_menu.restart_requested.connect(_on_restart_requested)
		_pause_menu.exit_requested.connect(_on_exit_requested)


func _show_options_menu() -> void:
	_push_menu(_options_menu)


func _show_credits_menu() -> void:
	_push_menu(_credits_menu)


func _push_menu(menu: Control) -> void:
	if not menu:
		return
	if not _menu_stack.is_empty():
		_menu_stack.back().visible = false
	elif _main_menu and _main_menu.visible:
		_main_menu.visible = false
	
	_menu_stack.append(menu)
	menu.visible = true
	_focus_first_element(menu)


func _focus_first_element(node: Node) -> void:
	if not node: return
	var first_focus: Control = _find_focusable_child(node)
	if first_focus:
		first_focus.grab_focus()


func _find_focusable_child(node: Node) -> Control:
	if node is Control and node.visible and node.focus_mode != Control.FOCUS_NONE:
		if node is Button or node is HSlider or node is VSlider or node is LineEdit:
			return node
	
	for child: Node in node.get_children():
		var found: Control = _find_focusable_child(child)
		if found:
			return found
	return null


func _pop_menu() -> void:
	if _menu_stack.is_empty():
		return
	_menu_stack.pop_back().visible = false
	if not _menu_stack.is_empty():
		_menu_stack.back().visible = true
		_focus_first_element(_menu_stack.back())
	elif GameManagerObject.current_state == GameManagerObject.GameState.MAIN_MENU:
		if _main_menu:
			_main_menu.visible = true
			_focus_first_element(_main_menu)


func _clear_menu_stack() -> void:
	for menu in _menu_stack:
		menu.visible = false
	_menu_stack.clear()


func _show_main_menu() -> void:
	GameManagerObject.set_state(GameManagerObject.GameState.MAIN_MENU)
	_main_menu.visible = true
	_focus_first_element(_main_menu)
	_fade_in()


func _on_start_requested() -> void:
	_begin_game_transition()


func _begin_game_transition() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	_clear_menu_stack()
	_fade_out()
	await get_tree().create_timer(_FADE_DURATION).timeout
	if is_instance_valid(_menu_layer):
		_menu_layer.queue_free()
	GameManagerObject.set_state(GameManagerObject.GameState.LOADING)
	_load_game_level()


func _load_game_level() -> void:
	var level_scene: PackedScene = load(start_level_path)
	var level: Node = level_scene.instantiate()
	_level_container.add_child(level)

	# Give engine 2 frames to process ready() calls before revealing the scene
	await get_tree().process_frame
	await get_tree().process_frame

	_fade_in()
	GameManagerObject.set_state(GameManagerObject.GameState.PLAYING)
	_is_transitioning = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if not _menu_stack.is_empty():
			if is_confirm_dialog_visible():
				_on_confirm_cancelled()
			elif GameManagerObject.current_state == GameManagerObject.GameState.PAUSED and _menu_stack.size() == 1:
				_toggle_pause() # Correctly handles unpausing
			else:
				_pop_menu()
			get_viewport().set_input_as_handled()
			return

	if event.is_action_pressed("pause"):
		if GameManagerObject.current_state == GameManagerObject.GameState.PLAYING:
			_toggle_pause()
			get_viewport().set_input_as_handled()
		elif GameManagerObject.current_state == GameManagerObject.GameState.PAUSED:
			_toggle_pause()
			get_viewport().set_input_as_handled()

	# Focus recovery: If directional input is detected but nothing is focused, snap focus to current menu
	if not get_viewport().gui_get_focus_owner():
		if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or \
		   event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
			var top_menu = _menu_stack.back() if not _menu_stack.is_empty() else null
			if is_confirm_dialog_visible():
				top_menu = _confirm_dialog
			elif GameManagerObject.current_state == GameManagerObject.GameState.MAIN_MENU:
				top_menu = _main_menu
			
			if top_menu:
				_focus_first_element(top_menu)
				get_viewport().set_input_as_handled()


func _toggle_pause() -> void:
	if _is_transitioning:
		return
	if not is_instance_valid(_pause_menu):
		return
	if GameManagerObject.current_state == GameManagerObject.GameState.PLAYING:
		GameManagerObject.set_state(GameManagerObject.GameState.PAUSED)
		get_tree().paused = true
		_push_menu(_pause_menu)
	elif GameManagerObject.current_state == GameManagerObject.GameState.PAUSED:
		if _menu_stack.size() > 1:
			_pop_menu()
			return
		_pop_menu()
		get_tree().paused = false
		GameManagerObject.set_state(GameManagerObject.GameState.PLAYING)


func _on_exit_requested() -> void:
	_show_confirm("EXIT GAME?\nAny unsaved progress will be lost.", func(): get_tree().quit())


func _on_main_menu_from_pause() -> void:
	_show_confirm("RETURN TO MAIN MENU?\nAny unsaved progress will be lost.", go_to_main_menu)


func _on_restart_requested() -> void:
	_show_confirm("RESTART GAME?\nAny unsaved progress will be lost.", restart_game)


func restart_game() -> void:
	get_tree().paused = false
	_clear_menu_stack()
	GameManagerObject.reset_game_state()
	for child in _level_container.get_children():
		child.queue_free()
	_begin_game_transition()


func go_to_main_menu() -> void:
	GameManagerObject.set_state(GameManagerObject.GameState.MAIN_MENU)
	_clear_menu_stack()
	GameManagerObject.reset_game_state()
	_fade_out()
	await get_tree().create_timer(_FADE_DURATION, true).timeout
	get_tree().paused = false
	for child in _level_container.get_children():
		child.queue_free()

	if not is_instance_valid(_menu_layer):
		_menu_layer = CanvasLayer.new()
		_menu_layer.layer = 5
		_menu_layer.name = "MainMenuLayer"
		_main_scene.add_child(_menu_layer)

		_main_menu = preload("res://ui/main_menu/main_menu.tscn").instantiate()
		_main_menu.name = "MainMenu"
		_menu_layer.add_child(_main_menu)
		_connect_menu_signals()

	_show_main_menu()


func _show_confirm(message: String, on_confirmed: Callable) -> void:
	if not is_instance_valid(_confirm_dialog):
		_confirm_dialog = _CONFIRM_SCENE.instantiate()
		_main_scene.get_node("ConfirmLayer").add_child(_confirm_dialog)
		_confirm_dialog.confirmed.connect(_on_confirm_accepted)
		_confirm_dialog.cancelled.connect(_on_confirm_cancelled)
	_pending_confirm_action = on_confirmed
	_confirm_dialog.setup(message)
	_confirm_dialog.visible = true
	_focus_first_element(_confirm_dialog)


func _on_confirm_accepted() -> void:
	_confirm_dialog.visible = false
	_pending_confirm_action.call()


func _on_confirm_cancelled() -> void:
	_confirm_dialog.visible = false


func _fade_out() -> void:
	_fade_rect.visible = true
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(_fade_rect, "modulate:a", 1.0, _FADE_DURATION)


func _fade_in() -> void:
	_fade_rect.visible = true
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(_fade_rect, "modulate:a", 0.0, _FADE_DURATION)
