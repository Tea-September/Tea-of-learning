class_name Teleporter
extends Interactable

@export_file("*.tscn") var path: String
@export var entry_point: String

func interact() -> void:
	# 由于父类内容被覆盖，重新调用父类的方法
	super()
	# 调用切换的场景的函数
	Game.change_scene(path, {entry_point = entry_point})
