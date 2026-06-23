extends Window

@export var game_data: GameData
@export var spin_input: SpinInput
@export var orbit_cam: OrbitCam
@export var momentum_mode_check_button: CheckButton
@export var change_base_spin_plus: Button
@export var change_base_spin_minus: Button
@export var change_base_spin_line_edit: LineEdit
@export var change_base_spin_increment: float = 10.0
@export var change_manual_spin_plus: Button
@export var change_manual_spin_minus: Button
@export var change_manual_spin_line_edit: LineEdit
@export var change_tool_spin_increment: float = 10.0
@export var input_mode_option_button: OptionButton
@export var show_detect_box_check_button: CheckButton
@export var camera_mode_option_button: OptionButton

func _ready() -> void:
	if momentum_mode_check_button:
		momentum_mode_check_button.toggled.connect(func(to: bool) -> void:
			if spin_input:
				spin_input._is_momentum_enabled = to
		)
	if momentum_mode_check_button and spin_input:
		momentum_mode_check_button.button_pressed=spin_input._is_momentum_enabled
	
	if change_base_spin_plus:
		change_base_spin_plus.pressed.connect(func() -> void:
			if game_data:
				game_data.increase_base_spin(change_base_spin_increment)
		)
	if change_base_spin_minus:
		change_base_spin_minus.pressed.connect(func() -> void:
			if game_data:
				game_data.increase_base_spin(-change_base_spin_increment)
		)
	
	if change_manual_spin_plus:
		change_manual_spin_plus.pressed.connect(func() -> void:
			if spin_input:
				if spin_input._is_momentum_enabled:
					spin_input.drag_force += change_tool_spin_increment
				else:
					spin_input.drag_sensitivity += change_tool_spin_increment
		)
	if change_manual_spin_minus:
		change_manual_spin_minus.pressed.connect(func() -> void:
			if spin_input:
				if spin_input._is_momentum_enabled:
					spin_input.drag_force -= change_tool_spin_increment
				else:
					spin_input.drag_sensitivity -= change_tool_spin_increment
		)
		
	if change_base_spin_line_edit:
		change_base_spin_line_edit.text_submitted.connect(func(to:String)->void:
			if game_data:
				game_data._base_spin=float(to)*(2.0 * PI)
		)
		
	if change_manual_spin_line_edit:
		change_manual_spin_line_edit.text_submitted.connect(func(to:String)->void:
			if spin_input:
				if spin_input._is_momentum_enabled:
					spin_input.drag_force=float(to)
				else:
					spin_input.drag_sensitivity=float(to)
		)
	
	for key in SpinInput.INPUT_MODE.keys():
		if input_mode_option_button:
			input_mode_option_button.add_item(key)
			
	if spin_input and input_mode_option_button:
		input_mode_option_button.select(spin_input.input_mode)
		
	if input_mode_option_button:
		input_mode_option_button.item_selected.connect(func(index: int) -> void:
			if spin_input:
				spin_input.input_mode = index
		)
		
	if show_detect_box_check_button:
		show_detect_box_check_button.toggled.connect(func(to: bool) -> void:
			if spin_input:
				spin_input.should_show_virtual_radius = to
		)
			
	for key in OrbitCam.MODE.keys():
		if camera_mode_option_button:
			camera_mode_option_button.add_item(key)
			
	if orbit_cam and camera_mode_option_button:
		camera_mode_option_button.select(orbit_cam.camera_mode)
		
	if camera_mode_option_button:
		camera_mode_option_button.item_selected.connect(func(index: int) -> void:
			if orbit_cam:
				orbit_cam.camera_mode = index
				orbit_cam.dragging = false
		)

func _process(delta: float) -> void:
	if game_data and change_base_spin_line_edit :
		if !change_base_spin_line_edit.is_editing():
			change_base_spin_line_edit.text = "%.2f" % [game_data._base_spin / (2.0 * PI)]
	
	if spin_input and change_manual_spin_line_edit:
		if !change_manual_spin_line_edit.is_editing():
			if spin_input._is_momentum_enabled:
				change_manual_spin_line_edit.text = "%.1f" % [spin_input.drag_force]
			else:
				change_manual_spin_line_edit.text = "%.1f" % [spin_input.drag_sensitivity]
