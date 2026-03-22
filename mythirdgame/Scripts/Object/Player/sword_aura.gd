extends CharacterBody2D

# 玩家属性
@onready var stats: Stats = Game.player_stats
@onready var graphics: Node2D = $Graphics
# 子弹速度
@export var bullet_speed : float = 150
var direction
var Player: Node2D
var player_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	if Player:
		player_position = Player.global_position
	# 你已有的初始化和实时更新逻辑
	Player = get_tree().get_first_node_in_group("player")
	# 调用判断方法，获取玩家方向
	direction = judge_player_direction()
	# 伤害
	stats.attack = 3
	graphics.scale.x = direction
	# 等待3秒，timeout为倒计时结束才能执行后面的代码
	await get_tree().create_timer(3).timeout
	# 销毁节点
	self.queue_free()

# 核心：判断玩家在当前节点左右（左返回-1，右返回1）
func judge_player_direction() -> int:
	if not Player:  # 防止玩家节点不存在报错
		return 0  # 无玩家时返回0（可根据需求修改）
	# 关键判断：对比当前节点与玩家的x坐标（2D场景核心逻辑）
	if Player.global_position.x < self.global_position.x:
		return 1  # 玩家在当前节点左边
	else:
		return -1   # 玩家在当前节点右边（x相等时也返回1，可微调）

func _physics_process(delta: float) -> void:
	# 通过更改全局坐标，来实现子弹的移动
	position += Vector2(bullet_speed, 0) * delta * direction
	

func _on_timer_timeout() -> void:
	# 销毁节点
	self.queue_free()

func _on_hit_box_area_entered(area: Area2D) -> void:
	area = area
	# 销毁节点
	self.queue_free()
