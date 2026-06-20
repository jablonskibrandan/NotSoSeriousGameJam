extends Node

@onready var current_year_length_label: Label = $CurrentYearLengthLabel
@onready var current_currency_label: Label = $CurrentCurrencyLabel

func _process(_delta: float) -> void:
	update_labels()
	
func update_labels() -> void:
	if current_year_length_label == null:
		return
	if current_currency_label == null:
		return
		
	current_year_length_label.text = "Current Year Length: " + str(GameManagerObject.current_year_length)
	current_currency_label.text = "MONEYYYYYY: " + str(GameManagerObject.current_currency)
