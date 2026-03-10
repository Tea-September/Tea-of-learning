extends Control

@export var stats: Stats

@onready var texture_progress_bar: TextureProgressBar = $PlayerMenuMargin/VBoxContainer/HBoxContainer/StateProgressBar/Health/TextureProgressBar
@onready var texture_progress_bar2: TextureProgressBar = $PlayerMenuMargin/VBoxContainer/HBoxContainer/StateProgressBar/Health/TextureProgressBar/TextureProgressBar
@onready var texture_progress_bar3: TextureProgressBar = $PlayerMenuMargin/VBoxContainer/HBoxContainer/StateProgressBar/Energy/TextureProgressBar

func _ready() -> void:
	if not stats:
		stats = Game.player_stats
	# 将信号，连接到对应函数
	stats.health_changed.connect(update_health)
	stats.energy_changed.connect(update_energy)
	# 初始化该函数
	update_health(true)
	update_energy()

func update_health(skip_anim = false) -> void:
	var percentage = stats.health * 1.0 / stats.max_health
	texture_progress_bar.value = percentage
	if skip_anim:
		texture_progress_bar2.value = percentage
	else:
		# 补间动画，将进度条数值的减少，以动画的形式进行变化
		create_tween().tween_property(texture_progress_bar2, "value", percentage, 0.3)
	
func update_energy() -> void:
	var percentage = stats.energy * 1.0 / stats.max_energy
	# 补间动画，将进度条数值的减少，以动画的形式进行变化
	create_tween().tween_property(texture_progress_bar3, "value", percentage, 0.3)
