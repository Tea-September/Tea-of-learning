extends Node

@onready var player_stats: Stats = $PlayerStats
# 补间动画使用的幕布
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	# 将补间动画中使用的幕布的透明度，设置为0
	color_rect.color.a = 0

func change_scene(path: String, entry_point: String) -> void:
	var tree = get_tree()
	# 转场暂停
	tree.paused = true
	# 补间动画，切换场景时的淡入淡出
	var tween = create_tween()
	# 暂停时，tween继续运行
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	# 透明变黑
	tween.tween_property(color_rect, "color:a", 1, 0.2)
	# 等待补间动画结束
	await tween.finished
	
	# 切换场景
	tree.change_scene_to_file(path)
	# 等待，直到新场景出现以后
	await tree.tree_changed
	
	# 找到位于entry_points这个分组的相同节点
	for node in tree.get_nodes_in_group("entry_points"):
		if node.name == entry_point:
			# 将玩家移动到指定位置
			tree.current_scene.update_player(node.global_position)
			break

	# 暂停结束
	tree.paused = false
	# 补间动画，切换场景时的淡入淡出
	tween = create_tween()
	# 黑变透明
	tween.tween_property(color_rect, "color:a", 0, 0.2)
