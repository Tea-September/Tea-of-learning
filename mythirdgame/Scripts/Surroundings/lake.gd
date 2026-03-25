extends World

@onready var camera: Camera2D = $Player/Camera2D


func _ready() -> void:
	# camera_2d为设置极限坐标
	camera_2d.limit_right = 742
	camera_2d.limit_left = -686
	# 将相机立即设置到设定位置
	camera_2d.reset_smoothing()
	camera_2d.force_update_scroll()
	# 背景音乐
	if bgm:
		SoundManager.play_bgm(bgm)
func to_dict() -> Dictionary:
	var enemies_alive = []
	# 遍历enemies中所有敌人的状态
	for node in get_tree().get_nodes_in_group("enemies"):
		# 保存敌人节点的路径
		var path = get_path_to(node) as String
		# 将敌人状态保存到新的数组中
		enemies_alive.append(path)
	return {
		# 将状态以字典的方式返回
		enemies_alive = enemies_alive,
	}

func from_dict(dict: Dictionary) -> void:
	# 遍历enemies中所有敌人的状态
	for node in get_tree().get_nodes_in_group("enemies"):
		# 保存敌人节点的路径
		var path = get_path_to(node) as String
		# 如果path对应的怪物节点不在当前保存的数组中，则释放该怪物
		if path not in dict.enemies_alive:
			node.queue_free()

func _on_boos_died() -> void:
	await get_tree().create_timer(1).timeout
	Game.change_scene("res://Scenes/Surroundings/Map/game_end.tscn")
