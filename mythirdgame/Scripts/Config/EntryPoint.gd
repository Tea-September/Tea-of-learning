class_name EntryPoint
extends Marker2D

@export var direction = player.Direction.RIGHT

func _ready() -> void:
	# 在场景初始化的时候，将该节点加入到entry_points的分组里面，即玩家切换场景时的初始位置
	add_to_group("entry_points")
