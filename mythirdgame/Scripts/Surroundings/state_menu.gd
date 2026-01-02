extends Control

@export var stats: Stats

@onready var texture_progress_bar: TextureProgressBar = $PlayerMenuMargin/VBoxContainer/HBoxContainer/StateProgressBar/Health/TextureProgressBar
@onready var texture_progress_bar2: TextureProgressBar = $PlayerMenuMargin/VBoxContainer/HBoxContainer/StateProgressBar/Health/TextureProgressBar/TextureProgressBar
@onready var texture_progress_bar3: TextureProgressBar = $PlayerMenuMargin/VBoxContainer/HBoxContainer/StateProgressBar/Energy/TextureProgressBar

func _ready() -> void:
	stats.health_changed.connect(update_health)
	stats.energy_changed.connect(update_energy)
	update_health()

func update_health() -> void:
	var percentage = stats.health * 1.0 / stats.max_health
	texture_progress_bar.value = percentage
	# 补间动画，将进度条数值的减少，以动画的形式进行变化
	create_tween().tween_property(texture_progress_bar2, "value", percentage, 0.3)
	
func update_energy() -> void:
	var percentage = stats.energy * 1.0 / stats.max_energy
	# 补间动画，将进度条数值的减少，以动画的形式进行变化
	create_tween().tween_property(texture_progress_bar3, "value", percentage, 0.3)
