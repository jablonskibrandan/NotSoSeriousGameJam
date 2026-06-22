extends Control

@onready var object_name_label: Label = %ObjectNameLabel
@onready var actions_container: VBoxContainer = %ActionsContainer

const ACTION_ROW = preload("res://ui/shared/action_row.tscn")

var _tween: Tween


func _ready() -> void:
	# Clear editor placeholders immediately
	for c in actions_container.get_children():
		c.free()
	modulate.a = 0.0
	hide()


func show_prompt(obj_name: String, actions: Array) -> void:
	object_name_label.text = obj_name

	# Clear previous actions instantly
	for c in actions_container.get_children():
		c.free()

	for action in actions:
		var row: HBoxContainer = ACTION_ROW.instantiate()
		actions_container.add_child(row)
		row.setup(action.icon_path, action.action_name)

	show()
	if _tween: _tween.kill()
	_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "modulate:a", 1.0, 0.18)


func hide_prompt() -> void:
	if not visible: return
	if _tween: _tween.kill()
	_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "modulate:a", 0.0, 0.12)
	_tween.tween_callback(hide)
