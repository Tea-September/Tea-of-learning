extends Node

enum Bus { MASTER, SFX, SFX2, BGM }

@onready var sfx: Node = $SFX
@onready var world_bgm: AudioStreamPlayer = $WorldBgm
@onready var run: AudioStreamPlayer = $SFX/Run
@onready var if_run: bool = true

# 音效播放
func play_sfx(name: String) -> void:
	var Player = sfx.get_node(name) as AudioStreamPlayer
	if not player:
		return
	Player.play()

# 场景BGM播放
func play_bgm(stream: AudioStream) -> void:
	if world_bgm.stream == stream and world_bgm.playing:
		return
	world_bgm.stream = stream
	world_bgm.play()

# 按钮音效，聚焦&按下
func setup_ui_sounds(node: Node) -> void:
	var button = node as Button
	if button:
		button.pressed.connect(play_sfx.bind("UIPress"))
		button.focus_entered.connect(play_sfx.bind("UIFocus"))
	for child in node.get_children():
		setup_ui_sounds(child)

# 获取音量
func get_volume(bus_index: int) -> float:
	var db = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(db)

# 设置音量
func set_volume(bus_index: int, T: float) -> void:
	var db = linear_to_db(T)
	AudioServer.set_bus_volume_db(bus_index, db)
	
	
	
	
	
	
		
		
		
