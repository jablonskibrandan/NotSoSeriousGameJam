extends Control

signal close_requested()

const _DIM := 0.38
const _TWEEN_DUR := 0.14
const _FPS_OPTIONS: Array[int] = [0, 30, 60, 120]
const _WINDOW_MODES: Array[int] = [Window.MODE_FULLSCREEN, Window.MODE_WINDOWED, Window.MODE_MAXIMIZED]

@onready var _general_panel: Control = %GeneralPanel
@onready var _controls_panel: Control = %ControlsPanel

@onready var _general_tab_btn: Button = %GeneralTabBtn
@onready var _controls_tab_btn: Button = %ControlsTabBtn

@onready var _resolution_cycle = %ResolutionCycle
@onready var _window_mode_cycle = %WindowModeCycle
@onready var _fps_cycle = %FpsCycle
@onready var _vsync_toggle = %VsyncToggle

@onready var _master_slider: HSlider = %MasterSlider
@onready var _sfx_slider: HSlider = %SfxSlider
@onready var _music_slider: HSlider = %MusicSlider

@onready var _mouse_sensitivity_slider: HSlider = %MouseSensitivitySlider
@onready var _mouse_sensitivity_value_label: Label = %MouseSensitivityValueLabel
@onready var _binds_container: VBoxContainer = %BindsContainer

const _ROW_SCENE: PackedScene = preload("res://ui/menus/options_menu/keybind_row.tscn")

@onready var _back_btn: Button = %BackButton
@onready var _sfx_hover: AudioStreamPlayer = $SFX/Hover
@onready var _sfx_click: AudioStreamPlayer = $SFX/Click

var _staged_resolution: Vector2i


func _ready() -> void:
	_populate_resolution_cycle()
	_sync_general_ui()
	_sync_controls_ui()
	_build_keybind_rows()
	_show_tab(_general_panel, _general_tab_btn)

	for btn: Button in [_general_tab_btn, _controls_tab_btn, _back_btn]:
		btn.focus_mode = Control.FOCUS_ALL
		btn.add_theme_stylebox_override("focus", UIConstants.focus_style)
		btn.mouse_entered.connect(btn.grab_focus)
		btn.focus_entered.connect(_on_active_state_changed.bind(btn))
		btn.focus_exited.connect(_on_active_state_changed.bind(btn))

	for slider: HSlider in [_master_slider, _sfx_slider, _music_slider, _mouse_sensitivity_slider]:
		slider.focus_mode = Control.FOCUS_ALL
		slider.step = 0.05 if "vol" in slider.name.to_lower() else 0.01
		slider.add_theme_stylebox_override("focus", UIConstants.focus_style)
		slider.focus_entered.connect(_on_active_state_changed.bind(slider))
		slider.focus_exited.connect(_on_active_state_changed.bind(slider))

	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	if visible:
		await get_tree().process_frame
		_refresh_button_states()


func _refresh_button_states() -> void:
	for node: Control in [_general_tab_btn, _controls_tab_btn, _back_btn, _master_slider, _sfx_slider, _music_slider, _mouse_sensitivity_slider]:
		_on_active_state_changed(node)

	# D-Pad Navigation Corrections
	_general_tab_btn.focus_neighbor_right = _resolution_cycle.get_path()
	_controls_tab_btn.focus_neighbor_right = _mouse_sensitivity_slider.get_path()
	_back_btn.focus_neighbor_right = _master_slider.get_path()
	
	_resolution_cycle.focus_neighbor_left = _general_tab_btn.get_path()
	_mouse_sensitivity_slider.focus_neighbor_left = _controls_tab_btn.get_path()
	_master_slider.focus_neighbor_left = _general_tab_btn.get_path()
	_sfx_slider.focus_neighbor_left = _general_tab_btn.get_path()
	_music_slider.focus_neighbor_left = _general_tab_btn.get_path()


func _on_general_tab_pressed() -> void:
	_sfx_click.play()
	_show_tab(_general_panel, _general_tab_btn)


func _on_controls_tab_pressed() -> void:
	_sfx_click.play()
	_show_tab(_controls_panel, _controls_tab_btn)




func _on_back_pressed() -> void:
	_sfx_click.play()
	SettingsManager.save_settings()
	close_requested.emit()


func _on_resolution_selected(idx: int) -> void:
	SettingsManager.resolution = SettingsManager.get_available_resolutions()[idx]
	SettingsManager.apply_video()
	SettingsManager.save_settings()


func _on_window_mode_selected(idx: int) -> void:
	SettingsManager.window_mode = _WINDOW_MODES[idx]
	SettingsManager.apply_video()
	SettingsManager.save_settings()


func _on_vsync_toggled(enabled: bool) -> void:
	SettingsManager.vsync = enabled
	SettingsManager.apply_video()
	SettingsManager.save_settings()


func _on_fps_selected(idx: int) -> void:
	SettingsManager.fps_limit = _FPS_OPTIONS[idx]
	SettingsManager.apply_video()
	SettingsManager.save_settings()


func _on_master_changed(value: float) -> void:
	SettingsManager.master_vol = value
	SettingsManager.apply_audio()
	SettingsManager.save_settings()


func _on_sfx_changed(value: float) -> void:
	SettingsManager.sfx_vol = value
	SettingsManager.apply_audio()
	SettingsManager.save_settings()


func _on_music_changed(value: float) -> void:
	SettingsManager.music_vol = value
	SettingsManager.apply_audio()
	SettingsManager.save_settings()


func _on_mouse_sensitivity_changed(value: float) -> void:
	SettingsManager.mouse_sensitivity = value
	_mouse_sensitivity_value_label.text = "%.2f" % value
	SettingsManager.save_settings()


func _show_tab(panel: Control, active_btn: Button) -> void:
	_general_panel.visible = panel == _general_panel
	_controls_panel.visible = panel == _controls_panel
	for btn: Button in [_general_tab_btn, _controls_tab_btn]:
		btn.modulate = Color(1.2, 1.2, 1.2, 1.0) if btn == active_btn else Color(1, 1, 1, _DIM)


func _populate_resolution_cycle() -> void:
	var resolutions: Array[Vector2i] = SettingsManager.get_available_resolutions()
	var labels: Array[String] = []
	for res in resolutions:
		labels.append("%dx%d" % [res.x, res.y])
	_resolution_cycle.options = labels
	var current_idx: int = resolutions.find(SettingsManager.resolution)
	_resolution_cycle.current_index = maxi(current_idx, 0)


func _sync_general_ui() -> void:
	var mode_to_idx: Dictionary = {Window.MODE_FULLSCREEN: 0, Window.MODE_WINDOWED: 1, Window.MODE_MAXIMIZED: 2}
	_window_mode_cycle.current_index = mode_to_idx.get(SettingsManager.window_mode, 0)
	_vsync_toggle.is_on = SettingsManager.vsync
	var fps_idx: int = _FPS_OPTIONS.find(SettingsManager.fps_limit)
	_fps_cycle.current_index = maxi(fps_idx, 0)
	_master_slider.value = SettingsManager.master_vol
	_sfx_slider.value = SettingsManager.sfx_vol
	_music_slider.value = SettingsManager.music_vol


func _sync_controls_ui() -> void:
	_mouse_sensitivity_slider.value = SettingsManager.mouse_sensitivity
	_mouse_sensitivity_value_label.text = "%.2f" % SettingsManager.mouse_sensitivity


func _build_keybind_rows() -> void:
	for child in _binds_container.get_children():
		child.queue_free()
	for action: StringName in SettingsManager.REBINDABLE_ACTIONS:
		_binds_container.add_child(_make_bind_row(action))


func _make_bind_row(action: StringName) -> Control:
	var row: Control = _ROW_SCENE.instantiate()
	row.get_node("NameLabel").text = SettingsManager.ACTION_LABELS.get(action, action)

	var kbm_ev: InputEvent = SettingsManager.get_kbm_event_for(action)
	var kbm_icon = SettingsManager.get_icon_for_event(kbm_ev)
	if kbm_icon:
		row.get_node("KbmIcon").texture = kbm_icon

	return row


func _on_active_state_changed(node: Control) -> void:
	var is_active := UIConstants.is_button_active(node as Button) if node is Button else node.has_focus()
	node.pivot_offset = Vector2(node.size.x / 2 if node is Slider else 0, node.size.y / 2)
	
	var tween: Tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	if is_active:
		_sfx_hover.play()
		tween.tween_property(node, "modulate", UIConstants.HOVER_MODULATE, UIConstants.TWEEN_DURATION)
		tween.tween_property(node, "scale", UIConstants.HOVER_SCALE, UIConstants.TWEEN_DURATION)
	else:
		var is_active_tab := (node == _general_tab_btn and _general_panel.visible) or \
							 (node == _controls_tab_btn and _controls_panel.visible)
		var target_modulate = Color(1.2, 1.2, 1.2, 1.0) if is_active_tab else Color(1, 1, 1, UIConstants.DIM_ALPHA)
		tween.tween_property(node, "modulate", target_modulate, UIConstants.TWEEN_DURATION)
		tween.tween_property(node, "scale", Vector2.ONE, UIConstants.TWEEN_DURATION)


func _on_any_button_exit(btn: Button) -> void:
	var is_active_tab := (btn == _general_tab_btn and _general_panel.visible) or \
						 (btn == _controls_tab_btn and _controls_panel.visible)
	var tween: Tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	if is_active_tab:
		tween.tween_property(btn, "modulate", Color(1.2, 1.2, 1.2, 1.0), UIConstants.TWEEN_DURATION)
	else:
		tween.tween_property(btn, "modulate", Color(1, 1, 1, UIConstants.DIM_ALPHA), UIConstants.TWEEN_DURATION)
	tween.tween_property(btn, "scale", Vector2.ONE, UIConstants.TWEEN_DURATION)