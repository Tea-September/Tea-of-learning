extends Node2D

@onready var tile_map_layer_1: TileMapLayer = $Background/TileMapLayer1
@onready var camera_2d: Camera2D = $Player/Camera2D

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
	pass
