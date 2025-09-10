extends Node2D

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var camera_2d: Camera2D = $Player/Camera2D

func _ready() -> void:
	# 获得矩形框，以图块为单位
	var used = tile_map_layer.get_used_rect()
	# 转换，以像素为单位
	var tile_size = tile_map_layer.tile_set.tile_size
	# camera_2d.limit_top为设置顶部极限坐标，used.position为获取图块左上角坐标
	camera_2d.limit_top = used.position.y * tile_size.y
	camera_2d.limit_right = used.end.x * tile_size.x
	camera_2d.limit_bottom = used.end.y * tile_size.y
	camera_2d.limit_left = used.position.x * tile_size.x
	# 将相机立即设置到设定位置
	camera_2d.reset_smoothing()
