extends Node2D

# 保存场景中的节点到slime_scene，需要设置保存那个场景
@export var slime_scene : PackedScene
# 设置史莱姆生成时间的间隔
@export var spawn_timer : Timer
# 分数
@export var score : int
# 分数显示
@export var score_label : Label
# 游戏结束显示
@export var game_over_label : Label

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	# 减少史莱姆生成的时间
	spawn_timer.wait_time -= 0.2 * delta
	# 设置史莱姆生成最快的时间
	spawn_timer.wait_time = clamp(spawn_timer.wait_time, 1, 3)
	# 显示分数
	score_label.text = "Score: " + str(score)

# 随机生成史莱姆
func _spawn_slime() -> void:
	# 生成史莱姆节点
	var slime_node =slime_scene.instantiate()
	# 生成史莱姆的位置，固定X轴250，Y轴45~120随机
	slime_node.position = Vector2(250, randf_range(45, 115))
	# 将其添加进场景树
	get_tree().current_scene.add_child(slime_node)

# 显示游戏结束字幕
func show_game_over():
	# 修改游戏结束为显示
	game_over_label.visible = true
