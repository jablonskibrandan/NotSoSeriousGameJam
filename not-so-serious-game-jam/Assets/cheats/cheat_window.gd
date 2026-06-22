extends Window

@export var game_data:GameData
@export var spin_input:SpinInput
@export var MomentumModeCheckButton:CheckButton
@export var ChangeBaseSpinPlus:Button
@export var ChangeBaseSpinMinus:Button
@export var ChangeBaseSpinLabel:RichTextLabel
@export var change_base_spin_increment:float=10.0
@export var ChangeManualSpinPlus:Button
@export var ChangeManualSpinMinus:Button
@export var ChangeManualSpinLabel:RichTextLabel
@export var change_tool_spin_increment:float=10.0

func _ready() -> void:
	MomentumModeCheckButton.toggled.connect(func(to:bool):
		if spin_input:
			spin_input._enabled_momentum_mode=to
	)
	
	ChangeBaseSpinPlus.pressed.connect(func():
		if game_data:
			game_data.increase_base_spin(change_base_spin_increment)
	)
	ChangeBaseSpinMinus.pressed.connect(func():
		if game_data:
			game_data.increase_base_spin(-change_base_spin_increment)
	)
	
	ChangeManualSpinPlus.pressed.connect(func():
		if spin_input:
			if spin_input._enabled_momentum_mode:
				spin_input.drag_force+=change_tool_spin_increment
			else:
				spin_input.drag_sensitivity+=change_tool_spin_increment
	)
	ChangeManualSpinMinus.pressed.connect(func():
		if spin_input:
			if spin_input._enabled_momentum_mode:
				spin_input.drag_force-=change_tool_spin_increment
			else:
				spin_input.drag_sensitivity-=change_tool_spin_increment
	)

func _process(delta: float) -> void:
	if game_data:
		ChangeBaseSpinLabel.text="%f rps"%[game_data._base_spin/(2*PI)]
	
	if spin_input:
			if spin_input._enabled_momentum_mode:
				ChangeManualSpinLabel.text="Force: %.01f"%[spin_input.drag_force]
			else:
				ChangeManualSpinLabel.text="Sensitivity: %.01f"%[spin_input.drag_sensitivity]
