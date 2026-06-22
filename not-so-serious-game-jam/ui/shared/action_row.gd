extends HBoxContainer

@onready var icon: TextureRect = %Icon
@onready var action_label: Label = %ActionLabel


func setup(icon_path: String, action_name: String) -> void:
	action_label.text = action_name.to_upper()
	if icon_path != "":
		icon.texture = load(icon_path)
		icon.show()
	else:
		icon.hide()
