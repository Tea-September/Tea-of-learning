extends Control

@export var stats: Stats

@onready var texture_progress_bar: TextureProgressBar = $PlayerMenuMargin/VSplitContainer/HBoxContainer/Health/TextureProgressBar
@onready var texture_progress_bar2: TextureProgressBar = $PlayerMenuMargin/VSplitContainer/HBoxContainer/Health/TextureProgressBar/TextureProgressBar

func _ready() -> void:
	stats.health_changed.connect(update_health)
	update_health()

func update_health() -> void:
	var percentage = stats.health * 1.0 / stats.max_health
	texture_progress_bar.value = percentage
	# 补间动画，将进度条数值的减少，以动画的形式进行变化
	create_tween().tween_property(texture_progress_bar2, "value", percentage, 0.3)
