extends Node

const MENU_MUSIC = preload("res://Assets/audio/ambience/space_ambeince.ogg")
const FADE_DURATION = 2.0
const LOW_PASS_MAX = 20000
const LOW_PASS_MIN = 800

@onready var _player: AudioStreamPlayer = $MusicPlayer
@onready var _ui_click: AudioStreamPlayer = $SFX/Click
@onready var _ui_hover: AudioStreamPlayer = $SFX/Hover

var _music_bus_index: int
var _lp_filter: AudioEffectLowPassFilter


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_music_bus_index = AudioServer.get_bus_index("Music")
	_player.stream = MENU_MUSIC
	
	for i in AudioServer.get_bus_effect_count(_music_bus_index):
		var effect = AudioServer.get_bus_effect(_music_bus_index, i)
		if effect is AudioEffectLowPassFilter:
			_lp_filter = effect
			break
	
	GameManagerObject.state_changed.connect(_on_state_changed)
	_on_state_changed(GameManagerObject.current_state)


func play_ui_click() -> void:
	_ui_click.play()


func play_ui_hover() -> void:
	_ui_hover.play()


func set_muffled(muffled: bool) -> void:
	if not _lp_filter:
		return
		
	var target = LOW_PASS_MIN if muffled else LOW_PASS_MAX
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(_lp_filter, "cutoff_hz", target, 0.5)


func _on_state_changed(state: GameManagerObject.GameState) -> void:
	match state:
		GameManagerObject.GameState.MAIN_MENU, \
		GameManagerObject.GameState.ENDING, \
		GameManagerObject.GameState.GAMEOVER:
			_fade_in()
			set_muffled(false)
		GameManagerObject.GameState.PLAYING:
			_fade_out()
		GameManagerObject.GameState.PAUSED:
			set_muffled(true)


func _fade_in() -> void:
	if _player.playing and _player.volume_db > -5:
		return
	
	if not _player.playing:
		_player.play()
	
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(_player, "volume_db", 0.0, FADE_DURATION).from(-40.0)


func _fade_out() -> void:
	if not _player.playing:
		return
		
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(_player, "volume_db", -40.0, FADE_DURATION)
	tween.tween_callback(_player.stop)
