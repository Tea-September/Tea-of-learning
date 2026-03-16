class_name World
extends Node2D

# 可碰撞的砖块地图
@onready var tile_map_layer_1: TileMapLayer = $Background/TileMapLayer1
# 相机
@onready var camera_2d: Camera2D = $Player/Camera2D
# 玩家
@onready var Player: player = $Player

func _ready() -> void:
	# 包围所有图块，形成矩形框，包含position和end属性，分别是指左上角和右下角，都为从原点数第几个格子，position为负，end为正
	var used = tile_map_layer_1.get_used_rect().grow(-1)
	# 获取图块的长和宽，x为宽、y为长a，并且转换，以像素为单位
	var tile_size = tile_map_layer_1.tile_set.tile_size
	# camera_2d.limit_top为设置顶部极限坐标
	camera_2d.limit_top = used.position.y * tile_size.y
	camera_2d.limit_right = used.end.x * tile_size.x
	camera_2d.limit_bottom = used.end.y * tile_size.y
	camera_2d.limit_left = used.position.x * tile_size.x
	# 将相机立即设置到设定位置
	camera_2d.reset_smoothing()
	camera_2d.force_update_scroll()

func update_player(pos: Vector2, direction: player.Direction) -> void:
	# 将玩家移动到指定位置
	Player.global_position = pos
	# 玩家朝向
	Player.direction = direction
	# 将相机立即移动到玩家位置
	camera_2d.reset_smoothing()
	camera_2d.force_update_scroll()

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
