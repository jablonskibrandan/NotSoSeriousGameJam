class_name SplashScreen extends Control

@export var _time: float = 3
@export var _fade_time: float = 1

signal finished()

var _tween: Tween
var _is_finishing: bool = false

func start() -> void:
	modulate.a = 0
	show()
	_tween = create_tween()
	_tween.finished.connect(_finish)
	_tween.tween_property(self, "modulate:a", 1, _fade_time)
	_tween.tween_interval(_time)
	_tween.tween_property(self, "modulate:a", 0, _fade_time)


func skip() -> void:
	if _is_finishing:
		return
	if _tween and _tween.is_running():
		_tween.kill()
	_finish()


func _finish() -> void:
	if _is_finishing:
		return
	_is_finishing = true
	finished.emit()
	queue_free()
