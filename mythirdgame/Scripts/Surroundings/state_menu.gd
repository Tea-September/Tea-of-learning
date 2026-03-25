extends Control
@export var stats: Stats
# 健康条
@onready var texture_progress_bar: TextureProgressBar = $PlayerMenuMargin/VBoxContainer/HBoxContainer/StateProgressBar/Health/TextureProgressBar
# 健康条底部动画条
@onready var texture_progress_bar2: TextureProgressBar = $PlayerMenuMargin/VBoxContainer/HBoxContainer/StateProgressBar/Health/TextureProgressBar/TextureProgressBar
# 体力条
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
	# 存放当前血量百分比、0~1
	var percentage = stats.health * 1.0 / stats.max_health
	# 将前置的血条直接设置成扣除血量后的进度条比例
	texture_progress_bar.value = percentage
	if skip_anim:
		texture_progress_bar2.value = percentage
	else:
		# 补间动画，将底部血条进度条数值的减少，以动画的形式进行变化
		create_tween().tween_property(texture_progress_bar2, "value", percentage, 0.3)
func update_energy() -> void:
	# 存放当前体力百分比、0~1
	var percentage = stats.energy * 1.0 / stats.max_energy
	# 补间动画，将进度条数值的减少，以动画的形式进行变化
	create_tween().tween_property(texture_progress_bar3, "value", percentage, 0.3)
