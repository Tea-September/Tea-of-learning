class_name Interactable
extends Area2D

signal interacted

# 交互对象初始化
func _init() -> void:
	collision_layer = 0
	collision_mask = 0
	# 设定只寻找玩家的对象
	set_collision_mask_value(2, true)
	# 信号连接
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

# 按钮实际执行的操作
func interact() -> void:
	print("[Interact] %s" % name)
	interacted.emit()

# 玩家进入，创建对象
func _on_body_entered(Player: player) -> void:
	if Player.stats.health > 0:
		Player.create_interactable(self)

# 玩家离开，删除对象
func _on_body_exited(Player: player) -> void:
	Player.delete_interactable(self)
