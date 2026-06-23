extends Node

signal settings_applied()

const _CFG_PATH := "user://settings.cfg"

const DEFAULT_SENSITIVITY: float = 0.3
const DEFAULT_FPS_LIMIT: int = 0

const REBINDABLE_ACTIONS: Array[StringName] = [
	&"drag_object", &"pan_camera", &"zoom_in", &"zoom_out",
]

const ACTION_LABELS: Dictionary = {
	&"drag_object": "Spin Planet (Mouse)",
	&"pan_camera": "Pan Camera (Mouse)",
	&"zoom_in": "Zoom In",
	&"zoom_out": "Zoom Out",
}

const _KBM_KEY_NAMES: Dictionary = {
	KEY_ESCAPE: "Esc", KEY_CTRL: "Crtl", KEY_ENTER: "Enter",
	KEY_SHIFT: "Shift", KEY_CAPSLOCK: "CapsLock", KEY_TAB: "Tab",
	KEY_ALT: "Alt", KEY_SPACE: "Space", KEY_BACKSPACE: "BackSpace",
}

var master_vol: float = 1.0
var sfx_vol: float = 1.0
var music_vol: float = 1.0
var mouse_sensitivity: float = DEFAULT_SENSITIVITY
var fps_limit: int = DEFAULT_FPS_LIMIT
var vsync: bool = true
var window_mode: int = Window.MODE_FULLSCREEN
var resolution: Vector2i


func _ready() -> void:
	resolution = DisplayServer.screen_get_size()
	_load_settings()


func get_available_resolutions() -> Array[Vector2i]:
	var native: Vector2i = DisplayServer.screen_get_size()
	var list: Array[Vector2i] = [
		Vector2i(1280, 720),
		Vector2i(1920, 1080),
		Vector2i(2560, 1440),
		Vector2i(3840, 2160),
	]
	
	if native not in list:
		list.append(native)
		list.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.x < b.x)
	return list


func apply_audio() -> void:
	_set_bus_vol(&"Master", master_vol)
	_set_bus_vol(&"SFX", sfx_vol)
	_set_bus_vol(&"Music", music_vol)


func apply_video() -> void:
	get_tree().root.get_window().mode = window_mode as Window.Mode
	if window_mode == Window.MODE_WINDOWED:
		DisplayServer.window_set_size(resolution)
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED
	)
	Engine.max_fps = fps_limit
	settings_applied.emit()


func save_settings() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	cfg.set_value("audio", "master", master_vol)
	cfg.set_value("audio", "sfx", sfx_vol)
	cfg.set_value("audio", "music", music_vol)
	cfg.set_value("video", "res_x", resolution.x)
	cfg.set_value("video", "res_y", resolution.y)
	cfg.set_value("video", "window_mode", window_mode)
	cfg.set_value("video", "vsync", vsync)
	cfg.set_value("video", "fps_limit", fps_limit)
	cfg.set_value("controls", "mouse_sensitivity", mouse_sensitivity)
	cfg.save(_CFG_PATH)


func get_kbm_event_for(action: StringName) -> InputEvent:
	for ev: InputEvent in InputMap.action_get_events(action):
		if ev is InputEventKey or ev is InputEventMouseButton:
			return ev
	return null


func get_icon_dir() -> String:
	return "res://Assets/icons/input_icons/Keyboard_Mouse/White/"


func get_icon_path_for_event(ev: InputEvent) -> String:
	if not ev: return ""
	if ev is InputEventKey or ev is InputEventMouseButton:
		var file_name := _get_kbm_icon_filename(ev)
		if not file_name.is_empty(): return get_icon_dir() + file_name
	return ""


func get_icon_for_event(ev: InputEvent) -> Texture2D:
	var path := get_icon_path_for_event(ev)
	if path and ResourceLoader.exists(path):
		return load(path)
	return null


func _get_kbm_icon_filename(ev: InputEvent) -> String:
	if ev is InputEventKey:
		var key_event := ev as InputEventKey
		var k: int = key_event.keycode
		if k == KEY_NONE: k = key_event.physical_keycode
		if k == KEY_NONE: return ""
		var clean: String = _KBM_KEY_NAMES.get(k, OS.get_keycode_string(k))
		return "T_" + clean.replace(" ", "_").replace("Kp", "") + "_Key_White.png"
	elif ev is InputEventMouseButton:
		if ev.button_index == MOUSE_BUTTON_LEFT: return "T_Mouse_Left_Key_White.png"
		if ev.button_index == MOUSE_BUTTON_RIGHT: return "T_Mouse_Right_Key_White.png"
		if ev.button_index == MOUSE_BUTTON_MIDDLE: return "T_Mouse_Middle_Key_White.png"
	return ""


func _load_settings() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	if cfg.load(_CFG_PATH) != OK:
		apply_audio()
		apply_video()
		return
	
	master_vol = cfg.get_value("audio", "master", 1.0)
	sfx_vol = cfg.get_value("audio", "sfx", 1.0)
	music_vol = cfg.get_value("audio", "music", 1.0)
	
	var native: Vector2i = DisplayServer.screen_get_size()
	resolution = Vector2i(
		cfg.get_value("video", "res_x", native.x),
		cfg.get_value("video", "res_y", native.y),
	)
	
	window_mode = cfg.get_value("video", "window_mode", Window.MODE_FULLSCREEN)
	vsync = cfg.get_value("video", "vsync", true)
	fps_limit = cfg.get_value("video", "fps_limit", DEFAULT_FPS_LIMIT)
	mouse_sensitivity = cfg.get_value("controls", "mouse_sensitivity", DEFAULT_SENSITIVITY)
	
	apply_audio()
	apply_video()


func _set_bus_vol(bus: StringName, linear: float) -> void:
	var idx: int = AudioServer.get_bus_index(bus)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(linear, 0.001)))
