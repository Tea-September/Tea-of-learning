extends Node

# 保存文件的路径
const SAVE_PATH = "user://data.sav"

# 存放场景的名称，场景存放各自场景想要存放的数据
var world_states = {}

@onready var player_stats: Stats = $PlayerStats
# 补间动画使用的幕布
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	# 将补间动画中使用的幕布的透明度，设置为0
	color_rect.color.a = 0

func change_scene(path: String, params = {}) -> void:
	var tree = get_tree()
	# 转场暂停
	tree.paused = true
	# 补间动画，切换场景时的淡入淡出
	var tween = create_tween()
	# 暂停时，tween继续运行
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	# 透明变黑
	tween.tween_property(color_rect, "color:a", 1, 0.2)
	# 等待补间动画结束
	await tween.finished
	
	# 获取退出场景的名称，将数组中退出场景的状态更改为刚刚保存的状态
	var old_name = tree.current_scene.scene_file_path.get_file().get_basename()
	world_states[old_name] = tree.current_scene.to_dict()
	
	if "init" in params:
		params.init.call()
	
	# 切换场景，无法在访问前置场景
	tree.change_scene_to_file(path)
	# 等待，直到新场景出现以后
	await tree.tree_changed
	
	# 获取新场景的名称，将新场景的状态更改为旧的保存的状态
	var new_name = tree.current_scene.scene_file_path.get_file().get_basename()
	if new_name in world_states:
		tree.current_scene.from_dict(world_states[new_name])
	if "entry_point" in params:
		# 找到位于entry_points这个分组的相同节点
		for node in tree.get_nodes_in_group("entry_points"):
			if node.name == params.entry_point:
				# 将玩家移动到指定位置
				tree.current_scene.update_player(node.global_position, node.direction)
				break

	if "position" in params and "direction" in params:
		tree.current_scene.update_player(params.position, params.direction)

	# 暂停结束
	tree.paused = false
	# 补间动画，切换场景时的淡入淡出
	tween = create_tween()
	# 黑变透明
	tween.tween_property(color_rect, "color:a", 0, 0.2)

func save_game() -> void:
	var scene = get_tree().current_scene
	var scene_name = scene.scene_file_path.get_file().get_basename()
	world_states[scene_name] = scene.to_dict()
	var data = {
		world_states = world_states,
		stats = player_stats.to_dict(),
		scene = scene.scene_file_path,
		Player = {
			direction = scene.Player.direction,
			position = {
				x = scene.Player.global_position.x,
				y = scene.Player.global_position.y,
			},
		},
	}
	var json = JSON.stringify(data)
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		return
	file.store_string(json)
	

func load_game() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var json = file.get_as_text()
	var data = JSON.parse_string(json) as Dictionary
	
	change_scene(data.scene, {
			direction = data.Player.direction,
			position = Vector2(
				data.Player.position.x,
				data.Player.position.y
			),
			init = func ():
				world_states = data.world_states
				player_stats.from_dict(data.stats)
	})
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		load_game()
	
	
	
