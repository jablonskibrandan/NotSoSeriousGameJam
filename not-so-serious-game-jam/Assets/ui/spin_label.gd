extends RichTextLabel

@export var game:Game

func _process(delta: float) -> void:
	text="Spins: %d"%game.global_spins
