extends VBoxContainer

@onready var label1: Label = $Label
@onready var label2: Label = $Label2

func _ready() -> void:
	label1.text = "COINS:" + str(22)
	label2.text = "Score:" + str(33)
