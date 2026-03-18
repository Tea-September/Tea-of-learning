extends Enemy

var launch_velocity: Vector2 = Vector2(150, -60)  # 水平150，垂直上80，最终落点约向右100像素
var gravity: float = 100.0  # 匹配抛掷距离
var Player: Node2D
var player_position: Vector2 = Vector2.ZERO
@onready var bullet: CharacterBody2D = $"."

func _ready() -> void:
	SoundManager.play_sfx("SlimeAttack")
	if Player:
		player_position = Player.global_position
	# 你已有的初始化和实时更新逻辑（衔接无违和）
	Player = get_tree().get_first_node_in_group("player")  # 沿用你的玩家获取方式
	# 示例：调用判断方法，获取玩家方向（可直接用于你的抛掷逻辑）
	launch_velocity.x *= judge_player_direction()
	# 等待3秒，timeout为倒计时结束才能执行后面的代码
	await get_tree().create_timer(3).timeout
	# 销毁节点
	queue_free()
	
# 核心：判断玩家在当前节点左右（左返回-1，右返回1）
func judge_player_direction() -> int:
	if not Player:  # 防止玩家节点不存在报错
		return 0  # 无玩家时返回0（可根据需求修改）
	# 关键判断：对比当前节点与玩家的x坐标（2D场景核心逻辑）
	if Player.global_position.x < self.global_position.x:
		return -1  # 玩家在当前节点左边
	else:
		return 1   # 玩家在当前节点右边（x相等时也返回1，可微调）

func _physics_process(delta: float) -> void:
	# 垂直方向添加重力，模拟抛物线
	launch_velocity.y += gravity * delta
	# 更新位置，实现抛掷
	position += launch_velocity * delta
	# 发生碰撞，销毁节点
	if self.is_on_floor() or self.is_on_wall():
		# 销毁节点
		self.queue_free()
	move_and_slide()
