class_name player
extends CharacterBody2D

# 左右
enum Direction {
	LEFT = -1,
	RIGHT = 1
}
# 贴墙跳距离
const WALL_JUMP_VELOCITY = Vector2(600, -400)
# 被击飞距离
const REPEL_AMOUNT: float = 450.0
# 获取方向
@export var direction = Direction.RIGHT:
	set(v):
		direction = v
		if not is_node_ready():
			await ready
		graphics.scale.x = direction
# 移动速度
@export var move_speed: float
# 跳跃高度
@export var jump_speed: float
# 玩家基础攻击
@export var basic_attack: int = 1
# 是否能够连击
@onready var can_combo: bool = false
# 是否能够二段跳
@onready var double_jump: bool = true
# 是否开启能量条计时器
@onready var if_energy: bool = false
# 重力
@onready var default_gravity = ProjectSettings.get("physics/2d/default_gravity") as float
# 按下跳跃键会变成true，防止未松开跳跃键导致的连续跳跃
@onready var input_jump: bool = false
# 按下滑铲键会变成true，防止未松开跳跃键导致的连续滑铲
@onready var input_slide: bool = false
# 状态变化后的第一帧
@onready var is_first_tick: bool = false
# 判断是否按下左键
@onready var is_left_wall: bool = false
# 判断可以连击事件是否出现
@onready var is_combo_requested: bool = false
# 伤害对象
@onready var pending_damage: Damage
# 人物动画
@onready var animated: AnimatedSprite2D = $Graphics/AnimatedSprite2D
# 场景翻转
@onready var graphics: Node2D = $Graphics
# 离地延迟跳跃
@onready var coyote_timer: Timer = $CoyoteTimer
# 空中预备跳跃
@onready var prepare_jump_timer: Timer = $PrepareJumpTimer
# 空中预备滑铲
@onready var prepare_slide_timer: Timer = $PrepareSlideTimer
# 能量条恢复
@onready var energy_timer: Timer = $EnergyTimer
# 无敌时间
@onready var invincible_timer: Timer = $InvincibleTimer
# 贴墙检测射线
@onready var up_sliding_wall: RayCast2D = $Graphics/SlidingWall/UpSlidingWall
@onready var down_sliding_wall: RayCast2D = $Graphics/SlidingWall/DownSlidingWall
# 受击框
@onready var hurt_box: HurtBox = $Graphics/HurtBox
# 玩家是否可以输入
@onready var game_over: bool = true
# 玩家属性
@onready var stats: Stats = Game.player_stats
# 组件引用
@onready var player_input_ahead: PlayerInputAhead = $Method/Player/PlayerInputAhead
@onready var player_tick_physics: PlayerTickPhysics = $Method/Player/PlayerTickPhysics
@onready var player_move: PlayerMove = $Method/Player/PlayerMove
@onready var player_get_next_state: PlayerGetNextState = $Method/Player/PlayerGetNextState
@onready var player_transition_state: PlayerTransitionState = $Method/Player/PlayerTransitionState
# 确定交互对象
@onready var interacting_with: Array[Interactable]
# 交互对象
@onready var interacting: AnimatedSprite2D = $Interacting
# 暂停页面
@onready var paused: Control = $CanvasLayer/Paused
# 死亡页面
@onready var die_title: Control = $CanvasLayer/Die
# 暂停按钮
@onready var paused_button: MarginContainer = $CanvasLayer/MarginContainer
# 读取存档按钮
@onready var load_game: Button = $CanvasLayer/Die/Panel/VBoxContainer/MarginContainer2/VBoxContainer/LoadGame
# 按钮存放盒子
@onready var v_box_container1: VBoxContainer = $CanvasLayer/Paused/Panel/VBoxContainer/MarginContainer2/VBoxContainer
@onready var v_box_container2: VBoxContainer = $CanvasLayer/Die/Panel/VBoxContainer/MarginContainer2/VBoxContainer
# 继续游戏按钮
@onready var continue_button: Button = $CanvasLayer/Paused/Panel/VBoxContainer/MarginContainer2/VBoxContainer/Continue
#
@onready var is_game_over: bool = false

# 提前输入
func _unhandled_input(event: InputEvent) -> void:
	player_input_ahead._input_ahead(self, event)

# 状态执行函数
func tick_physics(state: int, delta: float) -> void:
	player_tick_physics._tick_physics(self, state, delta)
	
# 移动函数
func move(gravity: float, delta: float) -> void:
	player_move._move(self, gravity, delta)

# 滑铲函数
func slide(gravity: float, delta: float) -> void:
	player_move._slide(self, gravity, delta)
	
# 状态判断函数
func get_next_state(state: int) -> int:
	return player_get_next_state._get_next_state(self, state)

# 动画播放函数，只有在状态发送改变时调用
func transition_state(from: int, to: int) -> void:
	player_transition_state._transition_state(self, from, to)

# 施展伤害的对象
func _on_hurt_box_hurt(hitbox: HitBox) -> void:
	pending_damage = Damage.new()
	pending_damage.amount = hitbox.owner.stats.attack
	pending_damage.source = hitbox.owner

# 能量条恢复
func _on_energy_timer_timeout() -> void:
	# 能量条满时，标记为不可恢复，恢复计时器结束
	if stats.energy == stats.max_energy:
		if_energy = false
		energy_timer.stop()
	# 能量条未满时，能量增加
	if stats.energy < stats.max_energy:
		stats.energy += 1

# 创建可交互的对象，该函数是为预防可交互对象重叠
func create_interactable(T: Interactable) -> void:
	# 交互对象在数组中时返回退出，不在时，在数组末尾加入对象
	if T in interacting_with:
		return
	else:
		interacting_with.append(T)

# 删除对象
func delete_interactable(T: Interactable) -> void:
		interacting_with.erase(T)

# 死亡执行
func die() -> void:
	# 游戏结束记录
	is_game_over = true
	# 判断是否拥有存档（即读取存档按钮是否能够按取）
	load_game.disabled = not Game.has_save()
	paused_button.visible = false
	die_title.visible = true
	# 怪物无法检测玩家
	self.collision_layer = 0
	# 将键盘和鼠标聚焦一致
	load_game.grab_focus()
	# 判断信号是否已连接，未连接再执行连接
	for button in v_box_container2.get_children():
		# 检查button的mouse_entered信号是否未连接到button.grab_focus
		if not button.mouse_entered.is_connected(button.grab_focus):
			button.mouse_entered.connect(button.grab_focus)

# 暂停按钮
func _on_button_pressed() -> void:
	paused_button.visible = false
	get_tree( ).paused = true
	paused.visible = true
	# 将键盘和鼠标聚焦一致
	continue_button.grab_focus()
	# 判断信号是否已连接，未连接再执行连接
	for button in v_box_container1.get_children():
		# 检查button的mouse_entered信号是否未连接到button.grab_focus
		if not button.mouse_entered.is_connected(button.grab_focus):
			button.mouse_entered.connect(button.grab_focus)

# 继续游戏
func _on_continue_pressed() -> void:
	paused_button.visible = true
	get_tree( ).paused = false
	paused.visible = false

# 返回菜单
func _on_quit_menu_pressed() -> void:
	Game.back_to_title()

# 读取旧存档
func _on_load_game_pressed() -> void:
	Game.load_game()
