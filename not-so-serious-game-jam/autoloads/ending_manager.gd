extends Node

const ENDING_1_SCENE = preload("res://ui/endings/ending_1.tscn")
const ENDING_2_SCENE = preload("res://ui/endings/ending_2.tscn")
const ENDING_3_SCENE = preload("res://ui/endings/ending_3.tscn")
const GAMEOVER_SCENE = preload("res://ui/gameover/game_over.tscn")
const CREDITS_SCENE = preload("res://ui/credits/credits_cinematic.tscn")

var _current_overlay: Node

# for testing. need to comment out before final build
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				do_ending1()
			KEY_F2:
				do_ending2()
			KEY_F3:
				do_gameover()
			KEY_F4:
				do_ending3()


func do_ending1() -> void:
	_trigger_ending(ENDING_1_SCENE)


func do_ending2() -> void:
	_trigger_ending(ENDING_2_SCENE)


func do_ending3() -> void:
	_trigger_ending(ENDING_3_SCENE)


func _trigger_ending(scene: PackedScene) -> void:
	if GameManagerObject.current_state == GameManagerObject.GameState.ENDING:
		return
	
	GameManagerObject.set_state(GameManagerObject.GameState.ENDING)
	get_tree().paused = true
	_ensure_audio_processes(get_tree().root)
	_apply_camera_drift(8.0)
	
	var sfx_bus_idx: int = AudioServer.get_bus_index("SFX")
	if sfx_bus_idx != -1:
		AudioServer.set_bus_mute(sfx_bus_idx, true)
	
	if is_instance_valid(_current_overlay):
		_current_overlay.queue_free()
		
	var overlay: Node = scene.instantiate()
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(overlay)
	_current_overlay = overlay
	
	var anim := overlay.get_node("AnimationPlayer") as AnimationPlayer
	anim.play("show_ending")
	
	await anim.animation_finished
	_show_credits()


func do_gameover() -> void:
	do_ending3()


func _apply_camera_drift(duration: float) -> void:
	var cam: Camera3D = get_viewport().get_camera_3d()
	if cam:
		var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(cam, "fov", cam.fov - 5.0, duration)


func _show_credits() -> void:
	if is_instance_valid(_current_overlay):
		_current_overlay.queue_free()
	
	var credits: Node = CREDITS_SCENE.instantiate()
	credits.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(credits)
	_current_overlay = credits
	
	var anim := credits.get_node("AnimationPlayer") as AnimationPlayer
	anim.play("play_credits")
	
	await anim.animation_finished
	
	_on_menu_pressed()


func _on_restart_pressed() -> void:
	if is_instance_valid(_current_overlay):
		_current_overlay.queue_free()
	
	var sfx_bus_idx: int = AudioServer.get_bus_index("SFX")
	if sfx_bus_idx != -1:
		AudioServer.set_bus_mute(sfx_bus_idx, false)
		
	SceneManager.restart_game()


func _on_menu_pressed() -> void:
	if is_instance_valid(_current_overlay):
		if _current_overlay is CanvasLayer:
			_current_overlay.layer = 100
			
	var sfx_bus_idx: int = AudioServer.get_bus_index("SFX")
	if sfx_bus_idx != -1:
		AudioServer.set_bus_mute(sfx_bus_idx, false)
			
	await SceneManager.go_to_main_menu()
	
	if is_instance_valid(_current_overlay):
		_current_overlay.queue_free()


func _ensure_audio_processes(node: Node) -> void:
	if node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D:
			node.process_mode = Node.PROCESS_MODE_ALWAYS
	for child in node.get_children():
		_ensure_audio_processes(child)
