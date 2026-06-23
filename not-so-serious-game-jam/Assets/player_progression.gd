@icon("res://Assets/icons/icon_assets/addons/at-icons/node/cpu.svg")
extends Node
class_name PlayerProgression

@export var game_data:GameData
@export var spin_input:SpinInput

@export var inital_autospin:float= 2.0 * PI / 60.0
var _autospin:float=inital_autospin

const UPGRADE_DATA_JSON_PATH:="res://Assets/upgrades/UpgradeData.json"
var upgrade_data
var json:=JSON.new()
@export var owned_upgrades:Dictionary[int,int]

func _ready()->void:
	var json_as_text = FileAccess.get_file_as_string(UPGRADE_DATA_JSON_PATH)
	var error = json.parse(json_as_text)
	if error == OK:
		upgrade_data = json.data
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_as_text, " at line ", json.get_error_line())
	#Stole this from the docs basically, hopefully it works
	print(get_auto_spin_rad())
	
func _process(delta: float) -> void:
	game_data.increase_rotation(get_auto_spin_rad()*delta)
	spin_input.drag_force=get_manual_force()
	
func get_auto_spin_rad()->float:
	var auto_spin_rad:float=0.0
	for index in owned_upgrades:
		var _owned_count=owned_upgrades[index]
		prints("asdas",upgrade_data[str(index)]["AUTO_RPS"])
		var _rps:=float(upgrade_data[str(index)]["AUTO_RPS"])
		var _rad:=_rps*2*PI
		auto_spin_rad+=_rad*_owned_count
	return auto_spin_rad
	
func get_manual_force()->float:
	var spin_force:float=0.0
	for index in owned_upgrades:
		var _owned_count=owned_upgrades[index]
		var _force:=float(upgrade_data[str(index)]["FORCE"])
		spin_force+=_force*_owned_count
	return spin_force
